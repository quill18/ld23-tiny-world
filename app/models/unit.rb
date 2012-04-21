class Unit < ActiveRecord::Base
	validates :tag, :uniqueness => true

	def can_enter_tile?(tile)
		#raise tile.tile_type.inspect
		if tile.tile_type.movement_cost == 0 or (tile.tile_type.is_bubble_wall==1 && !self.is_bubble_walker)
			return false
		end

		return true
	end
end
