class MapVote < ActiveRecord::Base
	belongs_to :user
	belongs_to :map
end
