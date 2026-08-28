# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CardEffects::Priest do
  it 'records the revealed card as visible only to the actor, changing nothing' do
    game = Game.create!(state: 'in_round', round_number: 1, deck: %w[baron])
    me = game.participants.create!(name: 'Me', session_id: 's0', turn_order: 0, hand: %w[priest guard])
    target = game.participants.create!(name: 'Them', session_id: 's1', turn_order: 1, hand: %w[princess])
    game.update!(current_participant: me)

    result = PlayCard.call(game:, participant: me, card: 'priest', target:)

    expect(result.move.payload['outcome'])
      .to eq('revealed_card' => 'princess', 'visible_to' => [me.id])
    expect(target.reload.hand).to include('princess')
    expect(target).not_to be_eliminated
  end
end
