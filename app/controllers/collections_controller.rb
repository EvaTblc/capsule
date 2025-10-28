class CollectionsController < ApplicationController
  before_action :set_collection, except: [ :index, :create, :new ]
  before_action :authorize_view!, only: [ :show ]
  before_action :authorize_manage!, only: [ :edit, :update ]
  before_action :authorize_destroy!, only: [ :destroy ]

  def index
    # Affiche toutes les collections accessibles (owned + collaborated)
    @collections = current_user.accessible_collections
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

  def authorize_view!
    unless @collection.viewable_by?(current_user)
      redirect_to collections_path, alert: "Vous n'avez pas accès à cette collection."
    end
  end

  def authorize_manage!
    unless @collection.manageable_by?(current_user)
      redirect_to collections_path, alert: "Vous ne pouvez pas modifier cette collection."
    end
  end

  def authorize_destroy!
    unless @collection.destroyable_by?(current_user)
      redirect_to collections_path, alert: "Seul le propriétaire peut supprimer cette collection."
    end
  end

  def collection_params
    params.require(:collection).permit(:name, :image)
  end
end
