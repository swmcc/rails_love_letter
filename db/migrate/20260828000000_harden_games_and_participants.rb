# frozen_string_literal: true

class HardenGamesAndParticipants < ActiveRecord::Migration[8.1]
  def change
    remove_index :games, :code
    add_index :games, :code, unique: true

    change_table :participants, bulk: true do |t|
      t.change_null :name, false
      t.change_null :session_id, false
      t.change_default :tokens, from: nil, to: 0
    end
    add_index :participants, %i[game_id session_id], unique: true
  end
end
