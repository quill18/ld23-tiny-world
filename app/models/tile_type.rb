class TileType < ActiveRecord::Base
	validates :tag, :uniqueness => true

	def self.tags
		return self.connection.select_all("SELECT tag FROM tile_types GROUP BY tag").map { |r| r["tag"] }
	end
end
