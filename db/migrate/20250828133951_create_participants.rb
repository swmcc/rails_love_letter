# frozen_string_literal: true

class CreateParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :participants do |t|
      t.references :game, null: false, foreign_key: true
      t.string :name
      t.string :session_id
      t.integer :tokens
      t.boolean :eliminated, default: false

      t.timestamps
    end
    add_index :participants, :session_id
  end
end
