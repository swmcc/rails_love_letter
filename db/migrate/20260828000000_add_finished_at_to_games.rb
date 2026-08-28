# frozen_string_literal: true

class AddFinishedAtToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :finished_at, :datetime
  end
end
