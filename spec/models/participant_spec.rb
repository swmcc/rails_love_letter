# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Participant, type: :model do
  let(:game) { Game.create! }

  it 'requires a session ID' do
    participant = described_class.new(game:, name: 'Alice')

    expect(participant).not_to be_valid
    expect(participant.errors[:session_id]).to include("can't be blank")
  end

  it 'requires a unique session ID within a game' do
    described_class.create!(game:, name: 'Alice', session_id: 'session-1')

    duplicate = described_class.new(game:, name: 'Alice again', session_id: 'session-1')

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:session_id]).to include('has already been taken')
  end

  it 'allows the same session ID in different games' do
    described_class.create!(game:, name: 'Alice', session_id: 'session-1')

    participant = described_class.new(game: Game.create!, name: 'Alice', session_id: 'session-1')

    expect(participant).to be_valid
  end

  it 'defaults tokens to zero' do
    participant = described_class.create!(game:, name: 'Alice', session_id: 'session-1')

    expect(participant.tokens).to eq(0)
  end

  it 'enforces session uniqueness within a game in the database' do
    described_class.create!(game:, name: 'Alice', session_id: 'session-1')

    expect do
      described_class.insert!({ # -- exercises the database constraint
                                game_id: game.id,
                                name: 'Alice again',
                                session_id: 'session-1',
                                created_at: Time.current,
                                updated_at: Time.current
                              })
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
