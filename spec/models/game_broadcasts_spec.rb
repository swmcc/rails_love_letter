# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game, '#broadcast_refreshes' do
  it 'broadcasts a refresh to the game stream and the lobby on changes' do
    game = Game.create!
    allow(Turbo::StreamsChannel).to receive(:broadcast_refresh_to)

    game.update!(round_number: 1)

    expect(Turbo::StreamsChannel)
      .to have_received(:broadcast_refresh_to).with(game, any_args).at_least(:once)
    expect(Turbo::StreamsChannel)
      .to have_received(:broadcast_refresh_to).with('lobby', any_args).at_least(:once)
  end

  it 'refreshes the board when a participant joins (via touch)' do
    game = Game.create!
    allow(Turbo::StreamsChannel).to receive(:broadcast_refresh_to)

    game.participants.create!(name: 'Bea', session_id: 'sB')

    expect(Turbo::StreamsChannel)
      .to have_received(:broadcast_refresh_to).with(game, any_args).at_least(:once)
  end

  it 'refreshes when a move is recorded (via touch)' do
    game = Game.create!
    player = game.participants.create!(name: 'Cee', session_id: 'sC')
    allow(Turbo::StreamsChannel).to receive(:broadcast_refresh_to)

    game.moves.create!(participant: player, action: 'play', payload: { card: 'guard' })

    expect(Turbo::StreamsChannel)
      .to have_received(:broadcast_refresh_to).with(game, any_args).at_least(:once)
  end
end
