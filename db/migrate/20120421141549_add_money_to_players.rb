class AddMoneyToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :money, :integer, :default => 0

  end
end
