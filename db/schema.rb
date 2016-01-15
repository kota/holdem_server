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

ActiveRecord::Schema.define(version: 20160115101032) do

  create_table "games", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "state",                    limit: 255
    t.integer  "current_button_player_id", limit: 4
    t.float    "sb",                       limit: 24
    t.float    "bb",                       limit: 24
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "hand_actions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "hand_id",     limit: 4
    t.integer  "player_id",   limit: 4
    t.string   "action_type", limit: 255
    t.string   "round",       limit: 255
    t.float    "bet_amount",  limit: 24
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "hands", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "game_id",          limit: 4
    t.integer  "action_player_id", limit: 4
    t.float    "sb",               limit: 24
    t.float    "bb",               limit: 24
    t.string   "round",            limit: 255
    t.string   "flop",             limit: 255
    t.string   "turn",             limit: 255
    t.string   "river",            limit: 255
    t.float    "pot",              limit: 24
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "players", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "game_id",    limit: 4
    t.integer  "hand_id",    limit: 4
    t.integer  "pot_id",     limit: 4
    t.float    "chip",       limit: 24,  default: 0.0
    t.string   "hole_cards", limit: 255
    t.string   "state",      limit: 255, default: "ingame"
    t.integer  "position",   limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "pots", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.float    "amount",     limit: 24
    t.integer  "hand_id",    limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

end
