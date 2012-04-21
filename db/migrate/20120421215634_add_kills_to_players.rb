class AddKillsToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :kills, :integer, :default => 0

  end
end
