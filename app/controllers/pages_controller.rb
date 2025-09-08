class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home

  def home
  end

  def add_item
    @collection = Collection.find(session[:collection]["id"])
    @category = Category.find(session[:category]["id"])
  end
end
