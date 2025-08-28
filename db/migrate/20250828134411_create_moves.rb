# frozen_string_literal: true

class CreateMoves < ActiveRecord::Migration[8.0]
  def change
    create_table :moves do |t|
      t.references :game, null: false, foreign_key: true
      t.references :participant, null: false, foreign_key: true
      t.string :action
      t.jsonb :payload

      t.timestamps
    end
  end
end
