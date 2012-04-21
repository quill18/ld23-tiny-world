class Unit < ActiveRecord::Base
	validates :tag, :uniqueness => true
end
