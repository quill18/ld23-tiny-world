class CreateMaps < ActiveRecord::Migration
  def change
    create_table :maps do |t|
      t.references :user
      t.string :name
      t.text :description
      t.integer :height
      t.integer :width

      t.timestamps
    end
    add_index :maps, :user_id
  end
end
