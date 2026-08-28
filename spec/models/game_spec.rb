# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game, type: :model do
  it 'generates a code' do
    g = Game.create!
    expect(g.code).to be_present
  end

  it 'requires a unique code' do
    described_class.create!(code: 'ABC123')

    duplicate = described_class.new(code: 'ABC123')

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:code]).to include('has already been taken')
  end

  describe 'state machine' do
    it 'starts in the lobby state' do
      expect(Game.create!).to be_lobby
    end

    it 'moves lobby → in_round and stamps started_at' do
      game = Game.create!

      game.transition_to!(:in_round)

      expect(game).to be_in_round
      expect(game.started_at).to be_present
    end

    it 'moves in_round → round_over → in_round for the next round' do
      game = Game.create!(state: 'in_round')

      game.transition_to!(:round_over)
      game.transition_to!(:in_round)

      expect(game).to be_in_round
    end

    it 'stamps finished_at when the game ends' do
      game = Game.create!(state: 'in_round')

      game.transition_to!(:over)

      expect(game).to be_over
      expect(game.finished_at).to be_present
    end

    it 'rejects invalid transitions' do
      game = Game.create!

      expect { game.transition_to!(:over) }.to raise_error(Game::InvalidTransition)
      expect { game.transition_to!(:round_over) }.to raise_error(Game::InvalidTransition)
    end

    it 'rejects unknown states' do
      expect { Game.create!(state: 'limbo') }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#joinable?' do
    it 'is joinable only in the lobby and under the player cap' do
      game = Game.create!(max_players: 2)
      expect(game).to be_joinable

      game.participants.create!(name: 'A', session_id: 's1')
      game.participants.create!(name: 'B', session_id: 's2')
      expect(game).not_to be_joinable

      started = Game.create!(state: 'in_round')
      expect(started).not_to be_joinable
    end
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
      participant = game.participants.create!(name: 'Ada', session_id: 'session-ada')
      move = game.moves.create!(participant:, action: 'draw')
      game.update_columns(updated_at: cutoff - 1.second)

      described_class.cleanup_stale!(cutoff:)

      expect(Participant.exists?(participant.id)).to be(false)
      expect(Move.exists?(move.id)).to be(false)
    end
  end
end
