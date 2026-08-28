# frozen_string_literal: true

class AddFinishedAtToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :finished_at, :datetime
    add_index :games, :finished_at
  end
end
