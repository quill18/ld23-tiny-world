class Game < ActiveRecord::Base
	has_many :players, :dependent => :destroy
	validate :uniqueness_of_players

	belongs_to :map, :dependent => :destroy

	before_create :clone_map, :start_new_turn!

	has_many :game_units, :dependent => :destroy

	has_many :notifications, :dependent => :destroy

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

	def current_user
		return current_player.user
	end

	def winning_player
		return Player.find(self.winning_player_id)
	end

	def winning_user
		return winning_player.user
	end

	def add_unit!(x, y, unit_tag, player)
		# Blocked by unit?
		return {:message => "Blocked by unit!"} unless get_game_unit_at(x,y).nil?

		unit = Unit.where(:tag => unit_tag).first
		tile = self.map.get_tile_at(x,y)

		return {:message => "Not enough money!"} if player.money < unit.cost

		# Adjacent to castle?
		return {:message => "Not adjacent to castle!"} unless tile.adjacent_to_castle?(player.team_id)

		# Blocked by unpassable terrain?
		return {:message => "Unpassable terrain!"} unless unit.can_enter_tile?(tile)

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
		return {:game_units=> [game_unit]}
	end

	def move_unit!(fromX, fromY, toX, toY, player)
		game_unit = get_game_unit_at(fromX, fromY)

		return {:message => "No unit at (#{x},#{y})!  JavaScript fail."} if game_unit.nil?

		return {:message => "Not your unit!"} if game_unit.team_id != self.current_team_id

		return {:message => "Out of movement!"} if game_unit.movement_left <= 0

		other_game_unit = get_game_unit_at(toX, toY)
		unless other_game_unit.nil?
			if other_game_unit.team_id == game_unit.team_id
				return {:message => "One of your units is in the way!"}
			else
				return fight_unit!(game_unit, other_game_unit)
			end
		end

		fromTile = self.map.get_tile_at(fromX, fromY)
		toTile = self.map.get_tile_at(toX, toY)

		return {:message => "Unpassable terrain!"} unless game_unit.unit.can_enter_tile?(toTile)

		movementLeft = game_unit.unit.speed

		path = get_path(fromTile, toTile, movementLeft)

		return {:message => "Pathfinding failed."} if path.nil?
		
		game_unit.movement_left -= toTile.tile_type.movement_cost
		game_unit.movement_left = 0 if game_unit.movement_left < 0
		
		game_unit.x = path.last.x
		game_unit.y = path.last.y

		game_unit.save!

		return {:game_units => [game_unit]}
	end

	def fight_unit!(game_unit, other_game_unit)

		damage = game_unit.unit.damage

		min_damage = damage / 2

		damage = min_damage + rand(damage) + 1

		damage -=  - other_game_unit.unit.defense

		other_game_unit.current_hitpoints -= damage
		if other_game_unit.current_hitpoints <= 0
			other_game_unit.destroy
			player = self.players.where(:team_id => game_unit.team_id).first
			player.kills += 1
			player.save!
		else
			other_game_unit.save!
		end

		game_unit.has_attacked = true
		game_unit.movement_left = 0

		game_unit.save!

		return {
			:game_units => [game_unit, other_game_unit], 
			:kills => kill_totals,
			:units => unit_totals
		}
	end

	def kill_totals
		t = {}
		for p in self.players
			t["team#{p.team_id}_kills"] = p.kills
		end
		return t #self.players.map {|p| {"team#{p.team_id}_kills" => p.kills} }
	end

	def unit_totals
		t = {}
		for p in self.players
			t["team#{p.team_id}_units"] = game_units_for_player(p).length
		end
		return t
		#return self.players.map {|p| {"team#{p.team_id}_units" => game_units_for_player(p).length } }
	end

	def get_game_unit_at(x,y)
		return game_units.where(:x => x, :y => y).first
	end

	def castles_for_player(player)
		castle_tag = "castle" + player.team_id.to_s

		tile_type = TileType.where(:tag => castle_tag)

		return self.map.tiles.where(:tile_type_id => tile_type)
	end

	def game_units_for_player(player)
		return self.game_units.where(:team_id => player.team_id)
	end

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

	def end_turn!
		# Flip castles
		for game_unit in self.game_units.where(:team_id => self.current_team_id)
			# Capture castles, if a unit is standing on one.
			tile = self.map.get_tile_at(game_unit.x, game_unit.y)
			if tile.tile_type.tag == "neutral_castle"
				tile.tile_type = TileType.where(:tag => ("castle" + self.current_team_id.to_s)).first
				tile.save!
			elsif tile.tile_type.tag =~ /^castle(\d+)$/
				if $1.to_i != self.current_team_id
					tile.tile_type = TileType.where(:tag => "neutral_castle").first
					tile.save!
				end
			end
		end

		self.current_team_id += 1
		if self.current_team_id > max_team_id
			self.current_team_id = 0
		end

		# Check for a winner
		update_winning_player_id

		if self.winning_player_id.nil?
			start_new_turn!()		
		end

		self.save!
	end

	def update_winning_player_id
		for player in self.players
			if castles_for_player(player).length == 0# or game_units_for_player(player).length == 0
				winning_player = self.players.where('team_id <> ?',player.team_id).first
				set_winning_player(winning_player)

				adjust_ratings(winning_player, player)

				notification = Notification.create(
						:game_id => self.id,
						:user_id => player.user.id,
						:message => "You were defeated!"
					)
				return
			end
		end
	end

	def set_winning_player(winning_player)
		self.winning_player_id = winning_player.id
		self.current_team_id = -winning_player.team_id
	end

	def user_surrender!(user)
		player_surrender!(player_from_user(user))
	end

	def player_surrender!(player)
		winner = opponent_for_player(player)
		set_winning_player( winner )
		self.save!
		notification = Notification.create(
				:game_id => self.id,
				:user_id => winning_user.id,
				:message => "Your opponent surrendered!"
			)
		adjust_ratings(winner, player)
	end

	def adjust_ratings(winner, loser)
		winner.user.xp += 10
		loser.user.xp  += 5

		# winning = 1
		# losing  = 0

		expected_score_winner = 1.0 / (  1.0 + 
				(
					10.0**((loser.user.elo.to_f - winner.user.elo.to_f) / 400.0) 
				)
			)


		expected_score_loser = 1.0 / (  1.0 + 
				(
					10.0**((winner.user.elo.to_f - loser.user.elo.to_f) / 400.0) 
				)
			)

		k = 32.0

		change_winner = k * (1.0 - expected_score_winner)
		change_loser  = k * (0.0 - expected_score_loser)

		winner.user.elo += change_winner.to_i
		loser.user.elo += change_loser.to_i

		winner.user.wins += 1
		loser.user.loses += 1

		winner.user.save!
		loser.user.save!
	end

	def opponent_for_user(user)
		return opponent_for_player(player_from_user(user))
	end

	def opponent_for_player(player)
		for p in self.players
			if player != p
				return p
			end
		end		
	end

	def start_new_turn!
		# Generate income
		for player in self.players
			if player.team_id == self.current_team_id
				player.money += castles_for_player(player).length * 5
				player.save!
			end
		end


		# Reset all the units
		for game_unit in self.game_units.where(:team_id => self.current_team_id)
			game_unit.movement_left = game_unit.unit.speed
			game_unit.has_attacked = false
			game_unit.save!
		end

		unless self.id.nil?
			notification = Notification.create(
					:game_id => self.id,
					:user_id => current_user.id,
					:message => "It's your turn!"
				)
		end
	end


end
