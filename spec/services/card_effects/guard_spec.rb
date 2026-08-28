# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CardEffects::Guard do
  def rigged_game(hands:)
    game = Game.create!(state: 'in_round', round_number: 1, deck: %w[priest baron])
    hands.each_with_index do |hand, i|
      game.participants.create!(name: "P#{i}", session_id: "s#{i}", turn_order: i, hand: Array(hand).map(&:to_s))
    end
    game.update!(current_participant: game.participants.by_turn_order.first)
    game
  end

  it 'eliminates the target on a correct guess and reveals their card' do
    game = rigged_game(hands: [%w[guard handmaid], %w[princess]])
    target = game.participants.by_turn_order.second

    result = PlayCard.call(game:, participant: game.current_participant,
                           card: 'guard', target:, guess: 'princess')

    expect(target.reload).to be_eliminated
    expect(target.hand).to be_empty
    expect(target.discards).to include('princess')
    expect(result.move.payload['outcome']).to include('guessed' => 'princess', 'hit' => true)
  end

  it 'does nothing on a wrong guess' do
    game = rigged_game(hands: [%w[guard handmaid], %w[baron]])
    target = game.participants.by_turn_order.second

    result = PlayCard.call(game:, participant: game.current_participant,
                           card: 'guard', target:, guess: 'princess')

    expect(target.reload).not_to be_eliminated
    expect(target.hand).to include('baron') # plus the card drawn as their turn opened
    expect(result.move.payload['outcome']).to include('hit' => false)
  end
end
