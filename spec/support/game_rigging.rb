# frozen_string_literal: true

# Puts a started game into a known mid-round position so gameplay specs are
# deterministic — hands are assigned in turn order and the deck is replaced
# wholesale (the shuffle in StartRound is bypassed).
module GameRigging
  def rig_round!(game, hands:, deck:, current: nil, burned: nil)
    game.participants.by_turn_order.zip(hands).each do |participant, hand|
      participant.update!(hand: Array(hand).map(&:to_s))
    end
    game.update!(
      deck: deck.map(&:to_s), burned_card: burned,
      current_participant: current || game.participants.by_turn_order.first
    )
    game
  end
end

RSpec.configure do |config|
  config.include GameRigging
end
