# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StartRound do
  def build_game(players: 3)
    game = Game.create!
    players.times { |i| game.participants.create!(name: "P#{i}", session_id: "s#{i}") }
    game
  end

  it 'accounts for all 16 cards across deck, burn, face-up and hands' do
    game = described_class.call(build_game(players: 3))

    hands = game.participants.flat_map(&:hand)
    total = game.deck + [game.burned_card] + game.face_up_cards + hands

    expect(total.sort).to eq(Card.deck.map { |c| c.key.to_s }.sort)
    expect(game.face_up_cards).to be_empty
    expect(hands.size).to eq(3)
  end

  it 'removes three extra face-up cards in a two-player game' do
    game = described_class.call(build_game(players: 2))

    expect(game.face_up_cards.size).to eq(3)
    expect(game.deck.size).to eq(16 - 1 - 3 - 2)
  end

  it 'deals exactly one card to every player and starts the round' do
    game = described_class.call(build_game(players: 4))

    expect(game.participants.map { |p| p.hand.size }).to all(eq(1))
    expect(game).to be_in_round
    expect(game.round_number).to eq(1)
    expect(game.current_participant).to eq(game.participants.by_turn_order.first)
  end

  it 'lets a named starter begin the round' do
    game = build_game(players: 3)
    winner = game.participants.last

    described_class.call(game, starter: winner)

    expect(game.current_participant).to eq(winner)
  end

  it 'refuses to start when a round is in progress' do
    game = described_class.call(build_game(players: 2))

    expect { described_class.call(game) }.to raise_error(StartRound::Error, /in progress/)
  end

  it 'refuses to start without 2-4 players' do
    expect { described_class.call(build_game(players: 1)) }
      .to raise_error(StartRound::Error, /2-4 players/)
  end

  it 'resets elimination, protection and discards between rounds' do
    game = described_class.call(build_game(players: 2))
    loser = game.participants.first
    loser.update!(eliminated: true, protected_until_turn: true, discards: %w[guard])
    game.transition_to!(:round_over)

    described_class.call(game, starter: game.participants.last)

    expect(loser.reload).not_to be_eliminated
    expect(loser.protected_until_turn).to be(false)
    expect(loser.discards).to be_empty
    expect(game.round_number).to eq(2)
  end
end
