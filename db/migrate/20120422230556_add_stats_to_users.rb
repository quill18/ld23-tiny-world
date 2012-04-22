class AddStatsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :xp, :integer, :default => 0
    add_column :users, :elo, :integer, :default => 1000
    add_column :users, :wins, :integer, :default => 0
    add_column :users, :loses, :integer, :default => 0
    add_column :users, :win_ratio, :float, :default => 0.0
  end
end
