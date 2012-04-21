class Tile < ActiveRecord::Base
	belongs_to :map
	belongs_to :tile_type

	default_scope :order => "y, x"

	def tile_type_tag
		self.tile_type.tag
	end

	def tile_type_tag=(tag)
		self.tile_type = TileType.find_by_tag(tag)
	end

	def adjacent_to_castle?(team_id, radius=1)
		castle_tiles = Tile.find_by_sql(["SELECT * FROM tiles WHERE map_id=? AND x BETWEEN ? AND ? AND y BETWEEN ? AND ? AND tile_type_id=? LIMIT 1",
					self.map_id,
					self.x-radius,
					self.x+radius,
					self.y-radius,
					self.y+radius,
					TileType.where(:tag => "castle#{team_id}").first.id]
				)

		if castle_tiles.empty?
			return false
		end

		return true
	end
end
