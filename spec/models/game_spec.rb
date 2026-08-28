# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game, type: :model do
  it 'generates a code' do
    g = Game.create!
    expect(g.code).to be_present
  end

  describe '.cleanup!' do
    it 'deletes finished games and unfinished games untouched for more than 24 hours' do
      cutoff = 24.hours.ago
      finished_game = Game.create!(finished_at: Time.current)
      stale_game = Game.create!
      boundary_game = Game.create!
      active_game = Game.create!
      stale_game.update!(updated_at: cutoff - 1.second)
      boundary_game.update!(updated_at: cutoff)

      deleted_games = described_class.cleanup!(cutoff: cutoff)

      expect(deleted_games).to contain_exactly(finished_game, stale_game)
      expect(described_class.where(id: [finished_game.id, stale_game.id])).to be_empty
      expect(described_class.where(id: [boundary_game.id, active_game.id]))
        .to contain_exactly(boundary_game, active_game)
    end
  end
end
