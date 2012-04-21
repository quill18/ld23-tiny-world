class CreateTileTypes < ActiveRecord::Migration
  def change
    create_table :tile_types do |t|
      t.integer :movement_cost, :default => 1
      t.integer :is_bubble_wall, :default => 0

      t.timestamps
    end
  end
end
