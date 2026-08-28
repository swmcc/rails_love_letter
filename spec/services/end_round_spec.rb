# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EndRound do
  def rigged(hands:, discards: [], tokens: [], deck: [])
    game = Game.create!(state: 'in_round', round_number: 1, deck: deck)
    hands.each_with_index do |hand, i|
      game.participants.create!(
        name: "P#{i}", session_id: "s#{i}", turn_order: i,
        hand: Array(hand).map(&:to_s), discards: discards[i] || [], tokens: tokens[i] || 0
      )
    end
    game.update!(current_participant: game.participants.by_turn_order.first)
    game
  end

  it 'awards the token to the last player standing' do
    game = rigged(hands: [%w[guard], [], []])
    game.participants.by_turn_order.to_a[1..].each { |p| p.update!(eliminated: true) }
    winner = game.participants.by_turn_order.first

    result = described_class.call(game, reason: :last_player_standing)

    expect(result[:round_winner]).to eq(winner)
    expect(winner.reload.tokens).to eq(1)
    expect(game.reload).to be_round_over
  end

  it 'resolves the deck-empty showdown by highest card' do
    game = rigged(hands: [%w[baron], %w[princess], %w[guard]])
    expected = game.participants.by_turn_order.second

    result = described_class.call(game, reason: :deck_empty)

    expect(result[:round_winner]).to eq(expected)
  end

  it 'breaks showdown ties by the sum of discard values' do
    game = rigged(hands: [%w[handmaid], %w[handmaid]],
                  discards: [%w[guard], %w[prince]])
    expected = game.participants.by_turn_order.second

    expect(described_class.call(game, reason: :deck_empty)[:round_winner]).to eq(expected)
  end

  it 'breaks a full tie by earliest turn order' do
    game = rigged(hands: [%w[handmaid], %w[handmaid]],
                  discards: [%w[guard], %w[guard]])

    expect(described_class.call(game, reason: :deck_empty)[:round_winner])
      .to eq(game.participants.by_turn_order.first)
  end

  it 'records a round_end move with the revealed hands' do
    game = rigged(hands: [%w[baron], %w[princess]])

    described_class.call(game, reason: :deck_empty)

    move = game.moves.find_by(action: 'round_end')
    expect(move.payload['reason']).to eq('deck_empty')
    expect(move.payload['hands'].values).to contain_exactly('baron', 'princess')
    expect(game.last_round_winner).to eq(move.participant)
  end

  it 'ends the game at the token target for the player count' do
    game = rigged(hands: [%w[guard], []], tokens: [6, 0]) # 2 players: first to 7
    game.participants.by_turn_order.second.update!(eliminated: true)

    result = described_class.call(game, reason: :last_player_standing)

    expect(result[:game_winner]).to eq(game.participants.by_turn_order.first)
    expect(game.reload).to be_over
    expect(game.finished_at).to be_present
  end

  it 'keeps the game going below the target and lets the winner start the next round' do
    game = rigged(hands: [%w[guard], []], tokens: [0, 0])
    game.participants.by_turn_order.second.update!(eliminated: true)
    winner = game.participants.by_turn_order.first

    described_class.call(game, reason: :last_player_standing)
    StartRound.call(game, starter: game.last_round_winner)

    expect(game.reload).to be_in_round
    expect(game.round_number).to eq(2)
    expect(game.current_participant).to eq(winner)
  end

  it 'uses 5 tokens for three players and 4 for four players' do
    expect(EndRound::TOKENS_TO_WIN).to eq({ 2 => 7, 3 => 5, 4 => 4 })
  end
end
