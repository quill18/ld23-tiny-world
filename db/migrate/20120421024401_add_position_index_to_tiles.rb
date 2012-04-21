class AddPositionIndexToTiles < ActiveRecord::Migration
  def change
  	add_index :tiles, :map_id
  	add_index :tiles, :x
  	add_index :tiles, :y
  end
end
