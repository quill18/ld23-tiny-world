class AddMovementLeftToGameUnits < ActiveRecord::Migration
  def change
    remove_column :game_units, :has_moved
    add_column :game_units, :movement_left, :integer

  end
end
