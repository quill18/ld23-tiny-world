class AddWinningPlayerIdToGames < ActiveRecord::Migration
  def change
    add_column :games, :winning_player_id, :integer

  end
end
