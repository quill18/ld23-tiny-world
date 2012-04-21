class AddCostToUnits < ActiveRecord::Migration
  def change
    add_column :units, :cost, :integer, :default => 10

  end
end
