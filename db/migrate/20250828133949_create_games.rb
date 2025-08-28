# frozen_string_literal: true

class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.string :code
      t.datetime :started_at
      t.integer :max_players

      t.timestamps
    end
    add_index :games, :code
  end
end
