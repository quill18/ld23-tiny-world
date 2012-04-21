class AddTagsToTilesAndUnits < ActiveRecord::Migration
  def change
    add_column :tile_types, :tag, :string
    add_column :units, :tag, :string
    add_index :tile_types, :tag
    add_index :units, :tag
  end
end
