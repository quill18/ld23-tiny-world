class AddTurnCounterToGames < ActiveRecord::Migration
  def change
    add_column :games, :turn_counter, :integer, :default => 0

  end
end
