class AddEmailOptionsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :notification_email_time, :integer, :default => 60
  end
end
