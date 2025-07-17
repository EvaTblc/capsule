class ItemsController < ApplicationController

  private
  
  def item_params
    params.require(:item).permit(:name, :possession, :state, photos: [])
  end
end
