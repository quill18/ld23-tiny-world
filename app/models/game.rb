class Game < ActiveRecord::Base
	has_many :players
	validate :uniqueness_of_players

	belongs_to :map

	before_create :clone_map

	has_many :game_units

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

	def player_from_user(user)
		return Player.where(:game_id => self.id, :user_id => user.id).first
	end

	def add_unit!(x, y, unit_tag, player)
		# Blocked by unit?
		return "Blocked by unit!" unless get_game_unit_at(x,y).nil?

		unit = Unit.where(:tag => unit_tag).first
		tile = self.map.get_tile_at(x,y)
		
		# Adjacent to castle?
		return "Not adjacent to castle!" unless tile.adjacent_to_castle?(player.team_id)

		# Blocked by unpassable terrain?
		return "Unpassable terrain!" unless unit.can_enter_tile?(tile)

		#return nil if player.money < unit.cost
	    player.money -= unit.cost
	    player.save!

		game_unit = GameUnit.new( 
			:unit_id => unit.id, 
			:x => x, 
			:y => y, 
			:team_id => player.team_id,
			:current_hitpoints => unit.hitpoints,
			:has_moved => true,
			:has_attacked => true 
			)

		self.game_units << game_unit
		self.save!
		return game_unit
	end

	def get_game_unit_at(x,y)
		return game_units.where(:x => x, :y => y).first
	end

end
