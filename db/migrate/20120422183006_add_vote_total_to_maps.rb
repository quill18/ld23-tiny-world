class AddVoteTotalToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :vote_total, :integer, :default => 0
    add_index :maps, :vote_total
  end
end
