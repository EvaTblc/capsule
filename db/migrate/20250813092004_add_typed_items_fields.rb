class AddTypedItemsFields < ActiveRecord::Migration[7.2]
  def change
    change_table :items do |t|
      t.string :type
      t.string :barcode
      t.string :barcode_type
      t.string :brand
      t.string :platform
      t.string :language
      t.date :released_on
      t.string :source
      t.string :source_id
      t.jsonb :metadata, default: {}
      t.jsonb :raw, default: {}
    end

    add_index :items, :type
    add_index :items, :barcode
    add_index :items, [ :collection_id, :barcode ]
    add_index :items, :metadata, using: :gin
  end
end
