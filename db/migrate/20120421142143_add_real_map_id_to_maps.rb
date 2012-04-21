class AddRealMapIdToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :real_map_id, :integer, :null => true, :default => nil

  end
end
