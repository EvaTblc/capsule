class ItemsController < ApplicationController
  before_action :set_item, except: [:index]

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

    @item.items_tags.build if @item.items_tags.empty?
  end

  def update
    @collection = Collection.find(params[:collection_id])
    @category = @collection.categories.find(params[:category_id])
    @item = @category.items.find(params[:id])

    attrs = item_params.dup
    attrs.delete(:photos) if attrs[:photos].blank? || attrs[:photos].all?(&:blank?)

    if params[:item][:photos].present?
      @item.photos.attach(params[:item][:photos])
    end

    if @item.update(item_params.except(:photos))
      redirect_to collection_category_item_path(@collection, @category, @item)
    else
      render :edit, status: :unprocessable_entity
    end

  end


  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :possession, :state, photos: [], items_tags_attributes: [:id, :name, :year, :comments, :_destroy])
  end
end
