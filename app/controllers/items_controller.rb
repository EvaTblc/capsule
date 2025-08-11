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

    # Si photos vide => on ne touche pas à l'existant
    permitted = item_params
    permitted.delete(:photos) if permitted[:photos].blank?

    if @item.update(permitted)
      # Suppression des photos marquées
      if params[:remove_photo_ids].present?
        @item.photos.where(id: params[:remove_photo_ids]).each(&:purge_later)
      end

      # Ajout des nouvelles photos
      if params.dig(:item, :photos).present?
        @item.photos.attach(params[:item][:photos])
      end

      redirect_to collection_category_item_path(@collection, @category, @item), notice: "Item mis à jour."
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
