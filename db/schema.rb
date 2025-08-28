# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_28_134411) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "games", force: :cascade do |t|
    t.string "code"
    t.datetime "started_at"
    t.integer "max_players"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_games_on_code"
  end

  create_table "moves", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "participant_id", null: false
    t.string "action"
    t.jsonb "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_moves_on_game_id"
    t.index ["participant_id"], name: "index_moves_on_participant_id"
  end

  create_table "participants", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.string "name"
    t.string "session_id"
    t.integer "tokens"
    t.boolean "eliminated", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_participants_on_game_id"
    t.index ["session_id"], name: "index_participants_on_session_id"
  end

  add_foreign_key "moves", "games"
  add_foreign_key "moves", "participants"
  add_foreign_key "participants", "games"
end
