# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength, Rails/BulkChangeTable
class HardenGamesAndParticipantsSchema < ActiveRecord::Migration[8.0]
  def up
    remove_index :games, :code if index_exists?(:games, :code)
    add_index :games, :code, unique: true unless index_exists?(:games, :code, unique: true)

    execute "UPDATE participants SET name = '' WHERE name IS NULL"
    execute "UPDATE participants SET session_id = 'legacy-' || id WHERE session_id IS NULL"
    execute 'UPDATE participants SET tokens = 0 WHERE tokens IS NULL'

    change_column_null :participants, :name, false
    change_column_null :participants, :session_id, false
    change_column_default :participants, :tokens, from: nil, to: 0

    remove_index :participants, :session_id if index_exists?(:participants, :session_id)
    return if index_exists?(:participants, %i[game_id session_id], unique: true)

    add_index :participants, %i[game_id session_id], unique: true
  end

  def down
    remove_index :participants, %i[game_id session_id] if index_exists?(:participants, %i[game_id session_id])
    add_index :participants, :session_id unless index_exists?(:participants, :session_id)

    change_column_default :participants, :tokens, from: 0, to: nil
    change_column_null :participants, :session_id, true
    change_column_null :participants, :name, true

    remove_index :games, :code if index_exists?(:games, :code)
    add_index :games, :code unless index_exists?(:games, :code)
  end
end
# rubocop:enable Metrics/MethodLength, Rails/BulkChangeTable
