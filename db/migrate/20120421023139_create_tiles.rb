class CreateTiles < ActiveRecord::Migration
  def change
    create_table :tiles do |t|
      t.integer :map_id
      t.integer :x
      t.integer :y
      t.integer :tile_type_id

      t.timestamps
    end
  end
end
