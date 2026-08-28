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

ActiveRecord::Schema[8.1].define(version: 2026_08_28_140000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "games", force: :cascade do |t|
    t.string "burned_card"
    t.string "code"
    t.datetime "created_at", null: false
    t.bigint "current_participant_id"
    t.jsonb "deck", default: [], null: false
    t.jsonb "face_up_cards", default: [], null: false
    t.datetime "finished_at"
    t.integer "max_players"
    t.integer "round_number", default: 0, null: false
    t.datetime "started_at"
    t.string "state", default: "lobby", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_games_on_code", unique: true
    t.index ["current_participant_id"], name: "index_games_on_current_participant_id"
    t.index ["finished_at"], name: "index_games_on_finished_at"
    t.index ["state"], name: "index_games_on_state"
  end

  create_table "moves", force: :cascade do |t|
    t.string "action"
    t.datetime "created_at", null: false
    t.bigint "game_id", null: false
    t.bigint "participant_id", null: false
    t.jsonb "payload"
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_moves_on_game_id"
    t.index ["participant_id"], name: "index_moves_on_participant_id"
  end

  create_table "participants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "discards", default: [], null: false
    t.boolean "eliminated", default: false
    t.bigint "game_id", null: false
    t.jsonb "hand", default: [], null: false
    t.string "name", null: false
    t.boolean "protected_until_turn", default: false, null: false
    t.string "session_id", null: false
    t.integer "tokens", default: 0
    t.integer "turn_order"
    t.datetime "updated_at", null: false
    t.index ["game_id", "session_id"], name: "index_participants_on_game_id_and_session_id", unique: true
    t.index ["game_id"], name: "index_participants_on_game_id"
    t.index ["session_id"], name: "index_participants_on_session_id"
  end

  add_foreign_key "games", "participants", column: "current_participant_id", on_delete: :nullify
  add_foreign_key "moves", "games"
  add_foreign_key "moves", "participants"
  add_foreign_key "participants", "games"
end
