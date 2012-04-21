class SetDefaultTeamIdForGame < ActiveRecord::Migration
  def up
  	change_column_default :games, :current_team_id, 0
  end

  def down
  end
end
