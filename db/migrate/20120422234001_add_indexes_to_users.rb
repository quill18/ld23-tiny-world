class AddIndexesToUsers < ActiveRecord::Migration
  def change
    add_index :users, :xp
    add_index :users, :elo
    add_index :users, :wins
    add_index :users, :loses
    add_index :users, :win_ratio
  end
end
