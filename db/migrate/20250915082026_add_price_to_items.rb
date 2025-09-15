class AddPriceToItems < ActiveRecord::Migration[7.2]
  def change
    add_column :items, :price, :float
  end
end
