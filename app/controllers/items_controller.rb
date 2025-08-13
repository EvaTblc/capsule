require "open-uri"
require "json"

class ItemsController < ApplicationController
  before_action :set_item, except: [ :index, :scan, :intake, :new, :create ]
  before_action :set_collection_category, only: [ :scan, :intake, :new, :create ]

  def index
    @collection = Collection.find(params[:collection_id])
    @category = Category.find(params[:category_id])
    @items = Item.where(collection: @collection, category: @category)
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
raise

    @item.items_tags.build if @item.items_tags.empty?
  end

  def update
    @collection = Collection.find(params[:collection_id])
    @category = @collection.categories.find(params[:category_id])
    @item = @category.items.find(params[:id])

    attrs = item_params.dup
    attrs.delete(:photos) if attrs[:photos].blank? || attrs[:photos].all?(&:blank?)
raise
    if params[:item][:photos].present?
      @item.photos.attach(params[:item][:photos])
    end

    if @item.update(item_params.except(:photos))
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

    klass = if barcode.start_with?("978", "979") && barcode.length == 13
              BookItem
            else
              Item
            end

    item = klass.find_or_initialize_by(
      collection_id: @collection.id,
      category_id:   @category.id,
      barcode:       barcode
    )

    if item.new_record?
      case klass.name
      when "BookItem" then api_book_item(item)
      # when "GameItem" ... etc.
      end

      item.name ||= "Nouvel objet"
      session[:scanned_item] = item.attributes
      redirect_to  new_collection_category_item_path(@collection, @category)
    end
  end

  def new
    @item = Item.new(collection: @collection, category: @category)
    data = session[:scanned_item] if session[:scanned_item].present?
    if data
      @item.name     = data["name"]
      @item.barcode  = data["barcode"]
      @item.source   = data["source"]
      @item.source_id= data["source_id"]
      @item.type     = data["type"] if data["type"].present? 
      @item.metadata = data["metadata"] if data["metadata"].is_a?(Hash)
      @item.raw = data["raw"] if data["raw"].is_a?(Hash)
    end

  end

  def create
    @item = Item.new(item_params)
    @item.collection = @collection
    @item.category = @category
    if @item.save!
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
    p = params.require(:item).permit(:name, :possession, :state, :type, :barcode, :source, :source_id, :metadata, :raw, photos: [])
    if p[:metadata].is_a?(String)
      p[:metadata] = JSON.parse(p[:metadata]) rescue {}
    end
    p
  end

  def api_book_item(item)
    url = "https://www.googleapis.com/books/v1/volumes?q=isbn:#{item.barcode}"
    item_serialized = URI.parse(url).read
    data = JSON.parse(item_serialized)

    if (info = data.dig("items", 0, "volumeInfo"))
      item.name = info["title"]
      item.metadata = {
        isbn_13: item.barcode,
        authors: info["authors"],
        publisher: info["publisher"],
        published_date: info["publishedDate"]
      }
      item.raw = info
    end
  end
end
