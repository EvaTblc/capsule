class AddImageUrlToCollections < ActiveRecord::Migration[7.2]
  def change
    add_column :collections, :image_url, :string
  end
end
