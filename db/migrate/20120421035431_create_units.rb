class CreateUnits < ActiveRecord::Migration
  def change
    create_table :units do |t|
      t.string  :name
      t.boolean :is_bubble_walker, :default => false
      t.integer :hitpoints, :default => 10
      t.integer :damage,    :default => 5
      t.integer :defense,   :default => 0
      t.integer :range,     :default => 1
      t.integer :speed,     :default => 2

      t.timestamps
    end
  end
end
