class CollectionsController < ApplicationController

  def index
    @collections = Collection.all.where(user: current_user)
  end

  private

  def collection_params
    params.require(:collection).permit(:name)
  end
end
