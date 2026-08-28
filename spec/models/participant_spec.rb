# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Participant, type: :model do
  let(:game) { Game.create! }

  it 'requires a name' do
    participant = game.participants.build(name: nil, session_id: 'session-1')

    expect(participant).not_to be_valid
    expect(participant.errors[:name]).to be_present
  end

  it 'requires a session_id' do
    participant = game.participants.build(name: 'Alice', session_id: nil)

    expect(participant).not_to be_valid
    expect(participant.errors[:session_id]).to be_present
  end

  it 'requires session_id to be unique per game' do
    game.participants.create!(name: 'Alice', session_id: 'session-1')
    duplicate = game.participants.build(name: 'Bob', session_id: 'session-1')

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:session_id]).to be_present
  end

  it 'allows the same session_id in different games' do
    game.participants.create!(name: 'Alice', session_id: 'session-1')
    other_game = Game.create!

    participant = other_game.participants.build(name: 'Alice', session_id: 'session-1')

    expect(participant).to be_valid
  end

  it 'defaults tokens to zero' do
    participant = game.participants.create!(name: 'Alice', session_id: 'session-1')

    expect(participant.tokens).to eq(0)
  end

  it 'enforces session_id uniqueness per game at the database level' do
    game.participants.create!(name: 'Alice', session_id: 'session-1')

    duplicate_attributes = {
      game_id: game.id,
      name: 'Bob',
      session_id: 'session-1',
      created_at: Time.current,
      updated_at: Time.current
    }

    expect do
      described_class.insert!(duplicate_attributes) # rubocop:disable Rails/SkipsModelValidations
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
# rubocop:enable Metrics/BlockLength
