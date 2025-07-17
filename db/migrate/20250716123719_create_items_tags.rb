class CreateItemsTags < ActiveRecord::Migration[7.2]
  def change
    create_table :items_tags do |t|
      t.integer :year
      t.string :name
      t.string :comments
      t.references :item, null: false, foreign_key: true

      t.timestamps
    end
  end
end
