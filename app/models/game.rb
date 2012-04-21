class Game < ActiveRecord::Base
	has_many :players
	validate :uniqueness_of_players

	belongs_to :map

	before_create :clone_map

	def clone_map
		cloned_map = self.map.dup
		cloned_map.real_map_id = self.map.id
		cloned_map.save!
		self.map = cloned_map
	end

	def uniqueness_of_players
		for player in self.players
			if self.players.index{ |p| p!=player && p.user==player.user }
				errors.add(:base, "LOL! Players can't play with themselves.  That's gross!")
			end
		end
	end
end
