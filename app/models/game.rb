class Game < ActiveRecord::Base
	has_many :players

	validate :uniqueness_of_players

	def uniqueness_of_players
		for player in self.players
			if self.players.index{ |p| p!=player && p.user==player.user }
				errors.add(:base, "LOL! Players can't play with themselves.  That's gross!")
			end
		end
	end
end
