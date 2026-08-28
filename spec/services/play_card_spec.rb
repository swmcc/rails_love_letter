# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlayCard do
  # Builds an in-round game with fixed hands so plays are deterministic.
  def rigged_game(hands:, deck: %w[guard priest baron])
    game = Game.create!(state: 'in_round', round_number: 1, deck: deck)
    hands.each_with_index do |hand, i|
      game.participants.create!(name: "P#{i}", session_id: "s#{i}", turn_order: i, hand: Array(hand).map(&:to_s))
    end
    game.update!(current_participant: game.participants.by_turn_order.first)
    game
  end

  def actor(game) = game.current_participant

  it 'rejects a play when the round is not in progress' do
    game = rigged_game(hands: [%w[guard handmaid], %w[priest]])
    game.update!(state: 'round_over')

    expect { described_class.call(game:, participant: actor(game), card: 'handmaid') }
      .to raise_error(PlayCard::Error, /not in progress/)
  end

  it 'rejects a play out of turn' do
    game = rigged_game(hands: [%w[guard handmaid], %w[priest]])
    other = game.participants.by_turn_order.second

    expect { described_class.call(game:, participant: other, card: 'priest') }
      .to raise_error(PlayCard::Error, /not your turn/)
  end

  it 'rejects playing a card you do not hold' do
    game = rigged_game(hands: [%w[guard handmaid], %w[priest]])

    expect { described_class.call(game:, participant: actor(game), card: 'king') }
      .to raise_error(PlayCard::Error, /do not hold/)
  end

  it 'forces the Countess when held with the King or Prince' do
    game = rigged_game(hands: [%w[king countess], %w[priest]])
    target = game.participants.by_turn_order.second

    expect { described_class.call(game:, participant: actor(game), card: 'king', target:) }
      .to raise_error(PlayCard::Error, /must play the Countess/)

    result = described_class.call(game:, participant: actor(game), card: 'countess')
    expect(result.move.payload['card']).to eq('countess')
  end

  it 'requires a target for targeted cards when a valid target exists' do
    game = rigged_game(hands: [%w[guard handmaid], %w[priest]])

    expect { described_class.call(game:, participant: actor(game), card: 'guard', guess: 'priest') }
      .to raise_error(PlayCard::Error, /Choose a player/)
  end

  it 'rejects protected or eliminated targets' do
    game = rigged_game(hands: [%w[baron handmaid], %w[priest], %w[king], %w[countess]])
    protected_p, eliminated_p, _open_target = game.participants.by_turn_order.to_a[1..]
    protected_p.update!(protected_until_turn: true)
    eliminated_p.update!(eliminated: true)

    expect { described_class.call(game:, participant: actor(game), card: 'baron', target: protected_p) }
      .to raise_error(PlayCard::Error, /cannot be targeted/)
    expect { described_class.call(game:, participant: actor(game), card: 'baron', target: eliminated_p) }
      .to raise_error(PlayCard::Error, /cannot be targeted/)
  end

  it 'allows a no-effect discard when every target is protected' do
    game = rigged_game(hands: [%w[guard handmaid], %w[priest]])
    game.participants.by_turn_order.second.update!(protected_until_turn: true)

    result = described_class.call(game:, participant: actor(game), card: 'guard')

    expect(result.move.payload['outcome']).to eq('no_effect' => true)
    expect(game.participants.by_turn_order.first.discards).to include('guard')
  end

  it 'validates the Guard guess' do
    game = rigged_game(hands: [%w[guard handmaid], %w[priest]])
    target = game.participants.by_turn_order.second

    expect { described_class.call(game:, participant: actor(game), card: 'guard', target:) }
      .to raise_error(PlayCard::Error, /Name a card/)
    expect { described_class.call(game:, participant: actor(game), card: 'guard', target:, guess: 'joker') }
      .to raise_error(PlayCard::Error, /Unknown card/)
    expect { described_class.call(game:, participant: actor(game), card: 'guard', target:, guess: 'guard') }
      .to raise_error(PlayCard::Error, /cannot guess the Guard/)
  end

  it 'allows the Prince to self-target but not the King' do
    game = rigged_game(hands: [%w[prince king], %w[priest]])
    me = actor(game)

    expect { described_class.call(game:, participant: me, card: 'king', target: me) }
      .to raise_error(PlayCard::Error, /cannot be targeted/)
  end

  it 'discards the played card, records the move and advances the turn' do
    game = rigged_game(hands: [%w[guard handmaid], %w[priest]])
    me = actor(game)
    second = game.participants.by_turn_order.second

    result = described_class.call(game:, participant: me, card: 'handmaid')

    expect(me.reload.hand).to eq(%w[guard])
    expect(me.discards).to eq(%w[handmaid])
    expect(result.move).to have_attributes(action: 'play', participant: me)
    expect(result.turn_signal).to eq(:drew)
    expect(game.reload.current_participant).to eq(second)
  end
end
