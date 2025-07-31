class CollectionsController < ApplicationController

  def index
    @collections = Collection.all.where(user: current_user)
  end

  def show
    @collection = Collection.find(params[:id])
  end

  def new
    @collection = Collection.new
  end
  def create
    @collection = Collection.new(collection_params)
    @collection.user = current_user
    if @collection.save!
      redirect_to collection_path(@collection)
    else
      render :new
    end
  end

  private

  def collection_params
    params.require(:collection).permit(:name, :image)
  end
end
