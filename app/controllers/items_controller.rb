class ItemsController < ApplicationController
  def show
    @item = Item.find(params[:id])
    @tags = ItemsTag.where(item: @item)
  end
  private

  def item_params
    params.require(:item).permit(:name, :possession, :state, photos: [])
  end
end
