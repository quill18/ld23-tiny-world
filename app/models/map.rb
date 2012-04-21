class Map < ActiveRecord::Base
  belongs_to :user
  has_many :tiles
  accepts_nested_attributes_for :tiles

  before_create :generate_tiles

  def generate_tiles
  	self.tiles.destroy

  	default_tile_type = TileType.first	# Open Water

    for y in 0..self.height-1
	  	for x in 0..self.width-1
	  		t = Tile.new
	  		t.x = x
	  		t.y = y
	  		t.tile_type = default_tile_type
	  		self.tiles << t
  		end
  	end
  end

  def get_tile_at(x,y)
    if self.tiles.loaded?
      return self.tiles[y*self.height + x]
    else
      return Tile.where(:map_id => self.id, :x => x, :y => y)
    end
  end
end
