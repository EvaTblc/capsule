class CategoriesController < ApplicationController
  before_action :set_category, except: [:index]

  def index
    @collection = Collection.find(params[:collection_id])
    @categories = Category.where(collection: @collection)
  end



  def update
    @collection = Collection.find(params[:collection_id])
    if @category.update(category_params)
      redirect_to collection_categories_path(Collection.find(params[:collection_id]))
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end
