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

ActiveRecord::Schema.define(version: 20180820012732) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "achievements", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "award_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     limit: 255
    t.text     "body"
    t.string   "resource_id",   limit: 255, null: false
    t.string   "resource_type", limit: 255, null: false
    t.integer  "author_id"
    t.string   "author_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "competitions", force: :cascade do |t|
    t.string   "country_code",          limit: 255
    t.string   "description",           limit: 255
    t.integer  "game_weeks_per_season"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contracts", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "team_player_id"
    t.integer  "weekly_salary_cents", limit: 8
    t.date     "starts_at"
    t.date     "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "player_id"
    t.boolean  "signed",                        default: false
  end

  add_index "contracts", ["player_id"], name: "index_contracts_on_player_id", using: :btree
  add_index "contracts", ["team_id"], name: "index_contracts_on_team_id", using: :btree
  add_index "contracts", ["team_player_id"], name: "index_contracts_on_team_player_id", using: :btree

  create_table "game_rounds", force: :cascade do |t|
    t.integer  "game_round_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "league_season_id"
  end

  add_index "game_rounds", ["league_season_id"], name: "index_game_rounds_on_league_season_id", using: :btree

  create_table "game_weeks", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "starts_at"
    t.integer  "season_id"
    t.integer  "game_week_number"
    t.boolean  "finished",             default: false
    t.datetime "ends_at"
    t.boolean  "financials_processed", default: false
  end

  add_index "game_weeks", ["season_id"], name: "index_game_weeks_on_season_id", using: :btree

  create_table "games", force: :cascade do |t|
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.integer  "game_week_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "game_round_id"
    t.integer  "home_team_score"
    t.integer  "away_team_score"
    t.boolean  "is_complete",     default: false, null: false
  end

  create_table "league_invites", force: :cascade do |t|
    t.integer  "league_id"
    t.string   "email",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "league_seasons", force: :cascade do |t|
    t.integer  "season_id"
    t.integer  "league_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "league_seasons", ["league_id"], name: "index_league_seasons_on_league_id", using: :btree
  add_index "league_seasons", ["season_id"], name: "index_league_seasons_on_season_id", using: :btree

  create_table "leagues", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "competition_id"
  end

  add_index "leagues", ["competition_id"], name: "index_leagues_on_competition_id", using: :btree
  add_index "leagues", ["user_id"], name: "index_leagues_on_user_id", using: :btree

  create_table "news_items", force: :cascade do |t|
    t.integer  "league_id"
    t.integer  "news_item_resource_id"
    t.string   "news_item_resource_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "body"
    t.string   "news_item_type",          limit: 255
    t.text     "content"
  end

  create_table "player_game_weeks", force: :cascade do |t|
    t.integer "minutes_played"
    t.integer "game_week_id"
    t.integer "player_id"
    t.float   "goals"
    t.boolean "clean_sheet"
    t.float   "goals_conceded"
    t.float   "assists"
    t.integer "player_value"
  end

  add_index "player_game_weeks", ["game_week_id"], name: "index_player_game_weeks_on_game_week_id", using: :btree
  add_index "player_game_weeks", ["player_id"], name: "index_player_game_weeks_on_player_id", using: :btree

  create_table "player_lineups", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "player_game_week_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "squad_position_id"
  end

  create_table "players", force: :cascade do |t|
    t.string   "first_name",                limit: 255
    t.string   "last_name",                 limit: 255
    t.string   "playing_position",          limit: 255
    t.integer  "pl_player_code"
    t.integer  "competition_id"
    t.integer  "pl_element_id"
    t.string   "real_team_short_name",      limit: 255
    t.boolean  "available",                             default: false
    t.datetime "game_week_deadline_at"
    t.string   "active_game_week_opponent", limit: 255
    t.string   "active_game_week_location", limit: 255
    t.string   "news",                      limit: 255
  end

  add_index "players", ["pl_player_code"], name: "index_players_on_pl_player_code", using: :btree

  create_table "seasons", force: :cascade do |t|
    t.string   "description",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "competition_id"
    t.date     "ends_at"
    t.date     "starts_at"
    t.boolean  "is_completed",               default: false, null: false
  end

  add_index "seasons", ["competition_id"], name: "index_seasons_on_competition_id", using: :btree

  create_table "squad_positions", force: :cascade do |t|
    t.string   "short_name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_order",             default: 0
    t.string   "long_name",  limit: 255
  end

  create_table "stadiums", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "capacity"
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "team_achievements", force: :cascade do |t|
    t.integer  "achievement_id"
    t.integer  "team_id"
    t.integer  "league_season_id"
    t.string   "details",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "team_players", force: :cascade do |t|
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "first_team",                       default: false
    t.integer  "player_id"
    t.integer  "squad_position_id"
    t.datetime "transfer_completes_at"
    t.boolean  "is_voluntary_transfer",            default: false, null: false
    t.integer  "transfer_minimum_bid"
    t.boolean  "is_team_player_initiated_listing", default: false, null: false
  end

  add_index "team_players", ["player_id"], name: "index_team_players_on_player_id", using: :btree
  add_index "team_players", ["team_id"], name: "index_team_players_on_team_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "title",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "league_id"
    t.integer  "cash_balance_cents", limit: 8
    t.datetime "deleted_at"
    t.integer  "number_of_titles"
  end

  add_index "teams", ["league_id"], name: "index_teams_on_league_id", using: :btree
  add_index "teams", ["user_id"], name: "index_teams_on_user_id", using: :btree

  create_table "transfer_items", force: :cascade do |t|
    t.integer  "transfer_id"
    t.string   "transfer_item_type", limit: 255
    t.integer  "team_player_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cash_cents",         limit: 8
    t.integer  "sending_team_id"
    t.integer  "receiving_team_id"
  end

  add_index "transfer_items", ["team_player_id"], name: "index_transfer_items_on_team_player_id", using: :btree
  add_index "transfer_items", ["transfer_id"], name: "index_transfer_items_on_transfer_id", using: :btree

  create_table "transfers", force: :cascade do |t|
    t.integer  "primary_team_id"
    t.integer  "secondary_team_id"
    t.boolean  "primary_team_accepted"
    t.boolean  "secondary_team_accepted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name",           limit: 255
    t.string   "last_name",            limit: 255
    t.string   "email",                limit: 255
    t.string   "password_digest",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_reset_token", limit: 255
    t.datetime "last_seen_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["password_reset_token"], name: "index_users_on_password_reset_token", using: :btree

end
