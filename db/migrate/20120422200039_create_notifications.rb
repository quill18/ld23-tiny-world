class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.integer :game_id
      t.text :message
      t.boolean :viewed, :default => false

      t.timestamps
    end

    add_index :notifications, :user_id
    add_index :notifications, :game_id
  end
end
