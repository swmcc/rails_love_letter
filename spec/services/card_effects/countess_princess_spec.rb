# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Countess and Princess effects' do
  def rigged(hands:)
    game = Game.create!(state: 'in_round', round_number: 1, deck: %w[guard guard])
    hands.each_with_index do |hand, i|
      game.participants.create!(name: "P#{i}", session_id: "s#{i}", turn_order: i, hand: Array(hand).map(&:to_s))
    end
    game.update!(current_participant: game.participants.by_turn_order.first)
    game
  end

  describe CardEffects::Countess do
    it 'is a clean no-op' do
      game = rigged(hands: [%w[countess king], %w[guard]])
      me = game.current_participant

      result = PlayCard.call(game:, participant: me, card: 'countess')

      expect(result.move.payload['outcome']).to eq({})
      expect(me.reload.hand).to eq(%w[king])
      expect(me).not_to be_eliminated
    end
  end

  describe CardEffects::Princess do
    it 'eliminates the player who plays her' do
      game = rigged(hands: [%w[princess guard], %w[baron]])
      me = game.current_participant

      result = PlayCard.call(game:, participant: me, card: 'princess')

      expect(me.reload).to be_eliminated
      expect(me.hand).to be_empty
      expect(me.discards).to contain_exactly('princess', 'guard')
      expect(result.move.payload['outcome']).to eq('eliminated_id' => me.id)
      expect(result.turn_signal).to eq(:last_player_standing)
    end
  end
end
