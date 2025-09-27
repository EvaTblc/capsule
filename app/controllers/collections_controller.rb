class CollectionsController < ApplicationController
  before_action :set_collection, except: [ :index, :create, :new ]
  def index
    @collections = Collection.all.where(user: current_user)
  end

  def new
    @collection = Collection.new
  end

  def create
    @collection = Collection.new(collection_params)
    @collection.user = current_user
    if @collection.save!
      redirect_to collection_categories_path(@collection)
    else
      render :new, status: :see_other
    end
  end

  def edit
    @collection = Collection.find(params[:id])
  end

  def update
    if @collection.update(collection_params)
      redirect_to collection_path(@collection)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @collection.destroy
      redirect_to collections_path
    else
      render :show, status: :see_other
    end
  end

  private

  def set_collection
    @collection = Collection.find(params[:id])
  end

  def collection_params
    params.require(:collection).permit(:name, :image)
  end
end
