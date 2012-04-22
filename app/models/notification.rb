class Notification < ActiveRecord::Base
	belongs_to :user
	belongs_to :game

	default_scope :order => "created_at DESC"

	def self.unread
		Notification.where(:viewed => 0)
	end
end
