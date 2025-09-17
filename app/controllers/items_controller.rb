require "open-uri"
require "json"

class ItemsController < ApplicationController
  before_action :set_item, except: [ :index, :scan, :intake, :new, :create ]
  before_action :set_collection_category, only: [ :scan, :intake, :new, :create ]

  def index
    @collection = Collection.find(params[:collection_id])
    @category = Category.find(params[:category_id])
    @items = Item.where(collection: @collection, category: @category)
    @item = Item.new

    if @category.items.empty? && @category.name == "Livre"
      redirect_to scan_collection_category_items_path(@collection, @category)
    end
    
  end
  def show
    @collection = Collection.find(params[:collection_id])
    @category = Category.find(params[:category_id])
    @item = Item.find(params[:id])
    @collection = Collection.find(params[:collection_id])
    @tags = ItemsTag.where(item: @item)
  end

  def edit
    @collection = Collection.find(params[:collection_id])
    @category   = Category.find(params[:category_id])

    @item.items_tags.build if @item.items_tags.empty?
  end

  def update
    @collection = Collection.find(params[:collection_id])
    @category   = @collection.categories.find(params[:category_id])
    @item       = @category.items.find(params[:id])

    attrs = item_params.dup
    files = attrs.delete(:photos) # idem : on enlève du hash

    if @item.update(attrs)
      @item.photos.attach(files.reject(&:blank?)) if files.present?
      redirect_to collection_category_item_path(@collection, @category, @item)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def scan
  end

  def intake
    barcode = params[:barcode].presence || params.dig(:item, :barcode).to_s
    barcode = barcode.strip
    return render(json: { error: "Barcode manquant" }, status: :unprocessable_entity) if barcode.blank?

    klass = (barcode.start_with?("978","979") && barcode.length == 13) ? BookItem : Item

    item = klass.find_or_initialize_by(
      collection_id: @collection.id,
      category_id:   @category.id,
      barcode:       barcode
    )

    if item.new_record?
      begin
        api_book_item(item) if klass == BookItem
      rescue => e
        Rails.logger.warn("[intake] enrichment failed: #{e.class} #{e.message}")
      end
      item.name ||= "Nouvel objet"
    end

    payload = {
      name: item.name,
      barcode: item.barcode,
      type: klass.name,
      source: item.source,
      source_id: item.source_id,
      metadata: item.metadata.presence || {}
    }

    Rails.logger.debug("[intake] item après enrichment: #{item.inspect}")

    if request.format.json?
      render json: payload, status: :ok
    else
      prefill = Base64.strict_encode64(payload.to_json)
      redirect_to new_collection_category_item_path(@collection, @category, prefill: prefill)
    end

  end

  def new
    @collection = Collection.find(params[:collection_id])
    @category   = @collection.categories.find(params[:category_id])

    prefill = {}
    if params[:prefill].present?
      prefill = JSON.parse(Base64.decode64(params[:prefill])) rescue {}
    end

    @item = @category.items.build(
      name:      prefill["name"],
      barcode:   prefill["barcode"],
      type:      prefill["type"],
      source:    prefill["source"],
      source_id: prefill["source_id"],
      metadata:  prefill["metadata"]
    )

  end

  def create
    attrs = item_params.dup
    files = attrs.delete(:photos) # on sort les fichiers du hash

    @item = @category.items.new(attrs)
    @item.collection = @collection

    if @item.save
      @item.photos.attach(files.reject(&:blank?)) if files.present?
      redirect_to collection_category_item_path(@collection, @category, @item)
    else
      render :new, status: :unprocessable_entity
    end
  end


  def destroy
    if @item.destroy
      redirect_to  collection_category_items_path
    else
      render :show, status: :see_other
    end
  end

  private

  def set_collection_category
    @collection = Collection.find(params[:collection_id])
    @category = Category.find(params[:category_id])
  end

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    p = params.require(:item).permit(:name, :possession, :state, :type, :barcode, :source, :source_id, :price,
    metadata: [:authors, :publisher, :language, :published_date, :description, :currency],
    photos: [])
    p[:metadata] = JSON.parse(p[:metadata]) rescue {} if p[:metadata].is_a?(String)
    p
  end

  def api_book_item(item)
    url = "https://www.googleapis.com/books/v1/volumes?q=isbn:#{item.barcode}"
    item_serialized = URI.parse(url).read
    data = JSON.parse(item_serialized)

    volume  = data.dig("items", 0) || {}
    info    = volume["volumeInfo"] || {}
    snippet = volume.dig("searchInfo", "textSnippet")

    return if info.blank?

    item.name = info["title"]

    item.metadata = {
      isbn_13:        item.barcode,
      authors:        info["authors"],       # peut être nil si absent
      publisher:      info["publisher"],
      published_date: info["publishedDate"],
      language:       info["language"],
      description:    info["description"] || snippet
    }.compact  # enlève juste les nil
    item.raw = volume
  end
end
