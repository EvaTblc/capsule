class CollectionsController < ApplicationController
  before_action :set_collection, except: [:index, :create, :new]
  def index
    @collections = Collection.all.where(user: current_user)
  end

  def show
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

  end

  private

  def set_collection
    @collection = Collection.find(params[:id])
  end

  def collection_params
    params.require(:collection).permit(:name, :image)
  end
end
