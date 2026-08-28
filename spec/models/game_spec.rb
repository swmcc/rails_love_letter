# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game, type: :model do
  it 'generates a code' do
    g = Game.create!
    expect(g.code).to be_present
  end

  describe '.cleanup_stale!' do
    let(:cutoff) { 24.hours.ago }

    it 'deletes games untouched before the cutoff' do
      old_game = Game.create!
      recent_game = Game.create!
      old_game.update_columns(updated_at: cutoff - 1.second)
      recent_game.update_columns(updated_at: cutoff + 1.second)

      expect { described_class.cleanup_stale!(cutoff:) }
        .to change(described_class, :count).by(-1)

      expect(described_class.exists?(old_game.id)).to be(false)
      expect(described_class.exists?(recent_game.id)).to be(true)
    end

    it 'deletes games finished before the cutoff even when recently touched' do
      old_finished_game = Game.create!(finished_at: cutoff - 1.second)
      recent_finished_game = Game.create!(finished_at: cutoff + 1.second)

      deleted = described_class.cleanup_stale!(cutoff:)

      expect(deleted).to eq(1)
      expect(described_class.exists?(old_finished_game.id)).to be(false)
      expect(described_class.exists?(recent_finished_game.id)).to be(true)
    end

    it 'keeps games exactly at the cutoff' do
      game = Game.create!(finished_at: cutoff)
      game.update_columns(updated_at: cutoff)

      expect { described_class.cleanup_stale!(cutoff:) }
        .not_to change(described_class, :count)
    end

    it 'destroys dependent participants and moves through callbacks' do
      game = Game.create!
      participant = game.participants.create!(name: 'Ada')
      move = game.moves.create!(participant:, action: 'draw')
      game.update_columns(updated_at: cutoff - 1.second)

      described_class.cleanup_stale!(cutoff:)

      expect(Participant.exists?(participant.id)).to be(false)
      expect(Move.exists?(move.id)).to be(false)
    end
  end
end
