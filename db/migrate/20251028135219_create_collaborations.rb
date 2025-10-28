class CreateCollaborations < ActiveRecord::Migration[7.2]
  def change
    create_table :collaborations do |t|
      t.references :collection, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, default: 1 # 0=viewer, 1=editor, 2=admin
      t.boolean :accepted

      t.timestamps
    end
  end
end
