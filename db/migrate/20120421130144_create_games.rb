class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :map_id
      t.integer :current_team_id

      t.timestamps
    end

    add_index :games, :map_id
  end
end
