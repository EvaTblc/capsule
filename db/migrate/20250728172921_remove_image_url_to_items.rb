class RemoveImageUrlToItems < ActiveRecord::Migration[7.2]
  def change
    remove_column :items, :image_url, :string
  end
end
