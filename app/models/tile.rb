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
end
