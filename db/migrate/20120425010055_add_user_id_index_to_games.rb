class AddUserIdIndexToGames < ActiveRecord::Migration
  def change
    add_index :games, :winning_player_id
  end
end
