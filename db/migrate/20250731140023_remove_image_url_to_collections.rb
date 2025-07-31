class RemoveImageUrlToCollections < ActiveRecord::Migration[7.2]
  def change
    remove_column :collections, :image_url, :string
  end
end
