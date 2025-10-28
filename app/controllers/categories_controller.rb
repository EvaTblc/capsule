class CategoriesController < ApplicationController
  before_action :set_category, except: [ :index, :create, :new ]
  before_action :set_collection

  def index
    if @collection.categories.empty?
      @category = Category.new
    else
      @categories = Category.where(collection: @collection)
    end
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    @category.collection = @collection
    if @category.save!
      redirect_to collection_categories_path(@collection)
    else
      render :index, status: :see_other
    end
  end

  def update
    if @category.update(category_params)
      redirect_to collection_categories_path(@collection)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      redirect_to collection_categories_path(@collection)
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def set_collection
    @collection = Collection.find(params[:collection_id])
  end

  def category_params
    params.require(:category).permit(:name, :photo)
  end
end
