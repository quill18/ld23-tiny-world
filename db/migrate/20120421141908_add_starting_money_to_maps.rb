class AddStartingMoneyToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :starting_money, :integer, :default => 50

  end
end
