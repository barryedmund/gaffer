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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151207064343) do

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true

  create_table "competitions", force: true do |t|
    t.string   "country_code"
    t.string   "description"
    t.integer  "rounds_per_season"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_weeks", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "season_id"
    t.datetime "starts_at"
    t.datetime "ends_at"
  end

  create_table "games", force: true do |t|
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.integer  "game_week_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leagues", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "competition_id"
  end

  add_index "leagues", ["competition_id"], name: "index_leagues_on_competition_id"
  add_index "leagues", ["user_id"], name: "index_leagues_on_user_id"

  create_table "player_game_weeks", force: true do |t|
    t.integer "minutes_played"
    t.integer "game_week_id"
    t.integer "player_id"
  end

  add_index "player_game_weeks", ["game_week_id"], name: "index_player_game_weeks_on_game_week_id"
  add_index "player_game_weeks", ["player_id"], name: "index_player_game_weeks_on_player_id"

  create_table "players", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "seasons", force: true do |t|
    t.string   "description"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "competition_id"
  end

  add_index "seasons", ["competition_id"], name: "index_seasons_on_competition_id"

  create_table "squad_positions", force: true do |t|
    t.string   "short_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_order", default: 0
  end

  create_table "team_players", force: true do |t|
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "first_team",        default: false
    t.integer  "player_id"
    t.integer  "squad_position_id"
  end

  add_index "team_players", ["player_id"], name: "index_team_players_on_player_id"
  add_index "team_players", ["squad_position_id"], name: "index_team_players_on_squad_position_id"
  add_index "team_players", ["team_id"], name: "index_team_players_on_team_id"

  create_table "teams", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "league_id"
  end

  add_index "teams", ["league_id"], name: "index_teams_on_league_id"
  add_index "teams", ["user_id"], name: "index_teams_on_user_id"

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_reset_token"
  end

  add_index "users", ["email"], name: "index_users_on_email"
  add_index "users", ["password_reset_token"], name: "index_users_on_password_reset_token"

end
