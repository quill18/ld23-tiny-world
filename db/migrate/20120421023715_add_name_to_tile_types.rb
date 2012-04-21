class AddNameToTileTypes < ActiveRecord::Migration
  def change
    add_column :tile_types, :name, :string

  end
end
