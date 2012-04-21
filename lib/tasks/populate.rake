namespace :populate do
	task :delete_maps => :environment do
		puts "Deleting maps"
		Map.destroy_all
	end

	task :tile_types => :environment do
		puts "Creating tile_types"

		raise "Delete maps before running populate:tile_types" if Map.all.length > 0

		TileType.destroy_all
		TileType.create(:name => "Open Water", :tag => "open-water")
		TileType.create(:name => "Bubbles", :tag => "bubbles", :is_bubble_wall => true)
		TileType.create(:name => "Weeds", :tag => "weeds", :movement_cost => 2)
		TileType.create(:name => "Logs", :tag => "logs", :movement_cost => 0)
		TileType.create(:name => "Red Castle", :tag => "red_castle")
		TileType.create(:name => "Blue Castle", :tag => "blue_castle")
	end

	task :units => :environment do
		puts "Creating units"
		Unit.destroy_all

		Unit.create(
				:name => "Goldfish",
				:tag => "goldfish",
				:is_bubble_walker => false,
				:hitpoints => 10,
       			:damage  => 5,
		        :defense => 0,
		        :range   => 1,
		        :speed   => 2

			)

		Unit.create(
				:name => "Seahorse",
				:tag => "seahorse",
				:is_bubble_walker => false,
				:hitpoints => 10,
       			:damage  => 5,
		        :defense => 0,
		        :range   => 1,
		        :speed   => 4

			)

		Unit.create(
				:name => "Turtle",
				:tag => "turtle",
				:is_bubble_walker => true,
				:hitpoints => 10,
       			:damage  => 5,
		        :defense => 2,
		        :range   => 1,
		        :speed   => 1

			)

		Unit.create(
				:name => "Swordfish",
				:tag => "swordfish",
				:is_bubble_walker => false,
				:hitpoints => 10,
       			:damage  => 10,
		        :defense => 0,
		        :range   => 1,
		        :speed   => 2

			)


	end

	task :all => [:tile_types, :units]
end

