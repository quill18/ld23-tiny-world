class Game < ActiveRecord::Base
	has_many :players
	validate :uniqueness_of_players

	belongs_to :map

	before_create :clone_map, :start_new_turn!

	has_many :game_units

	belongs_to :current_player, :class_name => "Player"

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

	def player_from_team_id(team_id)
		return Player.where(:game_id => self.id, :team_id => team_id).first
	end

	def current_player
		return player_from_team_id(self.current_team_id)
	end

	def add_unit!(x, y, unit_tag, player)
		# Blocked by unit?
		return "Blocked by unit!" unless get_game_unit_at(x,y).nil?

		unit = Unit.where(:tag => unit_tag).first
		tile = self.map.get_tile_at(x,y)

		return "Not enough money!" if player.money < unit.cost

		# Adjacent to castle?
		return "Not adjacent to castle!" unless tile.adjacent_to_castle?(player.team_id)

		# Blocked by unpassable terrain?
		return "Unpassable terrain!" unless unit.can_enter_tile?(tile)

	    player.money -= unit.cost
	    player.save!

		game_unit = GameUnit.new( 
			:unit_id => unit.id, 
			:x => x, 
			:y => y, 
			:team_id => player.team_id,
			:current_hitpoints => unit.hitpoints,
			:movement_left => 0,
			:has_attacked => true 
			)

		self.game_units << game_unit
		self.save!
		return game_unit
	end

	def move_unit!(fromX, fromY, toX, toY, player)
		game_unit = get_game_unit_at(fromX, fromY)

		return "No unit at (#{x},#{y})!  JavaScript fail." if game_unit.nil?

		return "Not your unit!" if game_unit.team_id != self.current_team_id

		return "Out of movement!" if game_unit.movement_left <= 0

		return "Combat code not implemented!" unless get_game_unit_at(toX, toY).nil?

		fromTile = self.map.get_tile_at(fromX, fromY)
		toTile = self.map.get_tile_at(toX, toY)

		movementLeft = game_unit.unit.speed

		path = get_path(fromTile, toTile, movementLeft)

		return false if path.nil?
		
		game_unit.movement_left -= 1
		game_unit.x = path.last.x
		game_unit.y = path.last.y

		game_unit.save!

		return game_unit
	end

	def get_game_unit_at(x,y)
		return game_units.where(:x => x, :y => y).first
	end

	def end_turn!
		self.current_team_id += 1
		if self.current_team_id > max_team_id
			self.current_team_id = 0
		end

		start_new_turn!()

		self.save!
	end


	private
	def get_path(fromTile, toTile, movementLeft)
		return nil if movementLeft < 0

		return nil if fromTile.path_checked?
		fromTile.path_checked!

		for x in -1..1
			for y in -1..1
				#logger.info "Checking tile at (#{fromTile.x + x}, #{fromTile.y + y})"
				t = self.map.get_tile_at(fromTile.x + x, fromTile.y + y)
				return [t] if toTile == t
			end
		end

		return nil
	end

	def max_team_id
		return self.players.maximum(:team_id)
	end

	def start_new_turn!
		# TODO: Generate income

		# Reset all the units
		for game_unit in self.game_units.where(:team_id => self.current_team_id)
			game_unit.movement_left = game_unit.unit.speed
			game_unit.has_attacked = false
			game_unit.save!
		end
	end


end
