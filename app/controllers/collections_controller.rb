class CollectionsController < ApplicationController

  def index
    @collections = Collection.all.where(user: current_user)
  end

  def show
    @collection = Collection.find(params[:id])
  end

  private

  def collection_params
    params.require(:collection).permit(:name, :image_url)
  end
end
