# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CardEffects::Baron do
  def rigged(actor_hand, target_hand)
    game = Game.create!(state: 'in_round', round_number: 1, deck: %w[guard guard])
    me = game.participants.create!(name: 'Me', session_id: 's0', turn_order: 0, hand: actor_hand)
    them = game.participants.create!(name: 'Them', session_id: 's1', turn_order: 1, hand: target_hand)
    game.update!(current_participant: me)
    [game, me, them]
  end

  it 'eliminates the target when the actor holds the higher card' do
    game, me, them = rigged(%w[baron princess], %w[guard])

    result = PlayCard.call(game:, participant: me, card: 'baron', target: them)

    expect(them.reload).to be_eliminated
    expect(result.move.payload['outcome']).to include('loser_id' => them.id)
  end

  it 'eliminates the actor when the target holds the higher card' do
    game, me, them = rigged(%w[baron guard], %w[princess])

    PlayCard.call(game:, participant: me, card: 'baron', target: them)

    expect(me.reload).to be_eliminated
    expect(them.reload).not_to be_eliminated
  end

  it 'does nothing on a tie' do
    game, me, them = rigged(%w[baron handmaid], %w[handmaid])

    result = PlayCard.call(game:, participant: me, card: 'baron', target: them)

    expect(me.reload).not_to be_eliminated
    expect(them.reload).not_to be_eliminated
    expect(result.move.payload['outcome']).to include('loser_id' => nil)
  end
end
