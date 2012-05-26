class AddPublishedToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :published, :boolean, :default => false
    Map.update_all( :published => true )
  end
end
