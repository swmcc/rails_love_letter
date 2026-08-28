# frozen_string_literal: true

class AddEngineStateToGamesAndParticipants < ActiveRecord::Migration[8.1]
  def change
    change_table :games, bulk: true do |t|
      t.string :state, null: false, default: 'lobby'
      t.jsonb :deck, null: false, default: []
      t.string :burned_card
      t.jsonb :face_up_cards, null: false, default: []
      t.bigint :current_participant_id
      t.integer :round_number, null: false, default: 0
      t.index :state
      t.index :current_participant_id
    end
    add_foreign_key :games, :participants, column: :current_participant_id, on_delete: :nullify

    change_table :participants, bulk: true do |t|
      t.jsonb :hand, null: false, default: []
      t.jsonb :discards, null: false, default: []
      t.boolean :protected_until_turn, null: false, default: false
      t.integer :turn_order
    end
  end
end
