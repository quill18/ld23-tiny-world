class ChangeViewedInNotifications < ActiveRecord::Migration
  def up
  	remove_column :notifications, :viewed
  	add_column :notifications, :viewed, :integer, :default => 0
  end

  def down
  end
end
