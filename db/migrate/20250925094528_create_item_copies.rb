class CreateItemCopies < ActiveRecord::Migration[7.2]
  def change
    create_table :item_copies do |t|
      t.references :item, null: false, foreign_key: true
      t.string :state
      t.decimal :price
      t.date :purchase_date
      t.text :notes

      t.timestamps
    end
  end
end
