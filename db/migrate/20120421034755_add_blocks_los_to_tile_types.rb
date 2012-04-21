class AddBlocksLosToTileTypes < ActiveRecord::Migration
  def change
    add_column :tile_types, :blocks_los, :boolean, :default => false

  end
end
