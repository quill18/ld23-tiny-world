class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.integer :user_id
      t.string :team_id_integer
      t.integer :game_id

      t.timestamps
    end
  end
end
