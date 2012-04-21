class CreateGameUnits < ActiveRecord::Migration
  def change
    create_table :game_units do |t|
      t.integer :game_id
      t.integer :team_id
      t.integer :unit_id
      t.integer :x
      t.integer :y
      t.integer :current_hitpoints
      t.boolean :has_moved
      t.boolean :has_attacked

      t.timestamps
    end
    add_index :game_units, :game_id
    add_index :game_units, :x
    add_index :game_units, :y
  end
end
