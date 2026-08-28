# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Handmaid, Prince and King effects' do
  def rigged(hands:, deck: %w[guard guard])
    game = Game.create!(state: 'in_round', round_number: 1, deck: deck, burned_card: 'baron')
    hands.each_with_index do |hand, i|
      game.participants.create!(name: "P#{i}", session_id: "s#{i}", turn_order: i, hand: Array(hand).map(&:to_s))
    end
    game.update!(current_participant: game.participants.by_turn_order.first)
    game
  end

  describe CardEffects::Handmaid do
    it 'protects the actor so opponents cannot target them' do
      game = rigged(hands: [%w[handmaid guard], %w[baron], %w[priest]])
      me = game.current_participant

      PlayCard.call(game:, participant: me, card: 'handmaid')

      expect(me.reload.protected_until_turn).to be(true)
      next_player = game.reload.current_participant
      expect do
        PlayCard.call(game:, participant: next_player, card: 'baron', target: me)
      end.to raise_error(PlayCard::Error, /cannot be targeted/)
    end
  end

  describe CardEffects::Prince do
    it 'makes the target discard without effect and draw a fresh card' do
      game = rigged(hands: [%w[prince guard], %w[handmaid]], deck: %w[countess])
      target = game.participants.by_turn_order.second

      result = PlayCard.call(game:, participant: game.current_participant,
                             card: 'prince', target:)

      expect(target.reload.discards).to eq(%w[handmaid])
      expect(target.hand).to eq(%w[countess])
      expect(target).not_to be_eliminated
      expect(result.move.payload['outcome']).to include('discarded' => 'handmaid', 'drew' => true)
    end

    it 'eliminates the target when they are forced to discard the Princess' do
      game = rigged(hands: [%w[prince guard], %w[princess]])
      target = game.participants.by_turn_order.second

      result = PlayCard.call(game:, participant: game.current_participant,
                             card: 'prince', target:)

      expect(target.reload).to be_eliminated
      expect(target.discards).to include('princess')
      expect(result.move.payload['outcome']).to include('eliminated_id' => target.id)
    end

    it 'draws the burned card when the deck is empty' do
      game = rigged(hands: [%w[prince guard], %w[handmaid]], deck: [])
      target = game.participants.by_turn_order.second

      PlayCard.call(game:, participant: game.current_participant, card: 'prince', target:)

      expect(target.reload.hand).to eq(%w[baron])
      expect(game.reload.burned_card).to be_nil
    end

    it 'may target the actor themselves' do
      game = rigged(hands: [%w[prince guard], %w[handmaid]], deck: %w[king])
      me = game.current_participant

      PlayCard.call(game:, participant: me, card: 'prince', target: me)

      expect(me.reload.discards).to eq(%w[prince guard])
      expect(me.hand).to eq(%w[king])
    end
  end

  describe CardEffects::King do
    it 'swaps hands with the target' do
      game = rigged(hands: [%w[king guard], %w[princess]])
      me = game.current_participant
      target = game.participants.by_turn_order.second

      PlayCard.call(game:, participant: me, card: 'king', target:)

      expect(me.reload.hand).to eq(%w[princess])
      expect(target.reload.hand).to include('guard') # plus their opening draw
    end
  end
end
