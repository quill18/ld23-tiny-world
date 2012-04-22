class ChangeViewedInNotifications < ActiveRecord::Migration
  def up
  	change_column :notifications, :viewed, :integer, :default => 0
  end

  def down
  end
end
