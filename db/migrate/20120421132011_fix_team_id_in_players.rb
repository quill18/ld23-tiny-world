class FixTeamIdInPlayers < ActiveRecord::Migration
  def up
  	remove_column :players, :team_id_integer
  	add_column :players, :team_id, :integer
  	add_index :players, :game_id
  	add_index :players, :user_id
  end

  def down
  end
end
