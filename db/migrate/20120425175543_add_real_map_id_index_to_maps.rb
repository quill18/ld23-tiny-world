class AddRealMapIdIndexToMaps < ActiveRecord::Migration
  def change
		add_index :maps, :real_map_id
  end
end
