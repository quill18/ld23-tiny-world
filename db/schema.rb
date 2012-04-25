# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120425010055) do

  create_table "game_units", :force => true do |t|
    t.integer  "game_id"
    t.integer  "team_id"
    t.integer  "unit_id"
    t.integer  "x"
    t.integer  "y"
    t.integer  "current_hitpoints"
    t.boolean  "has_attacked"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "movement_left"
  end

  add_index "game_units", ["game_id"], :name => "index_game_units_on_game_id"
  add_index "game_units", ["x"], :name => "index_game_units_on_x"
  add_index "game_units", ["y"], :name => "index_game_units_on_y"

  create_table "games", :force => true do |t|
    t.integer  "map_id"
    t.integer  "current_team_id",   :default => 0
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "winning_player_id"
  end

  add_index "games", ["map_id"], :name => "index_games_on_map_id"
  add_index "games", ["winning_player_id"], :name => "index_games_on_winning_player_id"

  create_table "map_votes", :force => true do |t|
    t.integer  "map_id"
    t.integer  "user_id"
    t.integer  "vote"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "map_votes", ["map_id"], :name => "index_map_votes_on_map_id"
  add_index "map_votes", ["user_id"], :name => "index_map_votes_on_user_id"

  create_table "maps", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "description"
    t.integer  "height"
    t.integer  "width"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "starting_money", :default => 50
    t.integer  "real_map_id"
    t.integer  "vote_total",     :default => 0
  end

  add_index "maps", ["user_id"], :name => "index_maps_on_user_id"
  add_index "maps", ["vote_total"], :name => "index_maps_on_vote_total"

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.text     "message"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "viewed",     :default => 0
  end

  add_index "notifications", ["game_id"], :name => "index_notifications_on_game_id"
  add_index "notifications", ["user_id"], :name => "index_notifications_on_user_id"

  create_table "players", :force => true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "team_id"
    t.integer  "money",      :default => 0
    t.integer  "kills",      :default => 0
  end

  add_index "players", ["game_id"], :name => "index_players_on_game_id"
  add_index "players", ["user_id"], :name => "index_players_on_user_id"

  create_table "tile_types", :force => true do |t|
    t.integer  "movement_cost",  :default => 1
    t.integer  "is_bubble_wall", :default => 0
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "name"
    t.boolean  "blocks_los",     :default => false
    t.string   "tag"
  end

  add_index "tile_types", ["tag"], :name => "index_tile_types_on_tag"

  create_table "tiles", :force => true do |t|
    t.integer  "map_id"
    t.integer  "x"
    t.integer  "y"
    t.integer  "tile_type_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "tiles", ["map_id"], :name => "index_tiles_on_map_id"
  add_index "tiles", ["x"], :name => "index_tiles_on_x"
  add_index "tiles", ["y"], :name => "index_tiles_on_y"

  create_table "units", :force => true do |t|
    t.string   "name"
    t.boolean  "is_bubble_walker", :default => false
    t.integer  "hitpoints",        :default => 10
    t.integer  "damage",           :default => 5
    t.integer  "defense",          :default => 0
    t.integer  "range",            :default => 1
    t.integer  "speed",            :default => 2
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "tag"
    t.integer  "cost",             :default => 10
  end

  add_index "units", ["tag"], :name => "index_units_on_tag"

  create_table "users", :force => true do |t|
    t.string   "email",                   :default => "",   :null => false
    t.string   "encrypted_password",      :default => "",   :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "nickname"
    t.integer  "notification_email_time", :default => 60
    t.integer  "xp",                      :default => 0
    t.integer  "elo",                     :default => 1000
    t.integer  "wins",                    :default => 0
    t.integer  "loses",                   :default => 0
    t.float    "win_ratio",               :default => 0.0
  end

  add_index "users", ["elo"], :name => "index_users_on_elo"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["loses"], :name => "index_users_on_loses"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["win_ratio"], :name => "index_users_on_win_ratio"
  add_index "users", ["wins"], :name => "index_users_on_wins"
  add_index "users", ["xp"], :name => "index_users_on_xp"

end
