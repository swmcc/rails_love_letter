# frozen_string_literal: true

# Moves the turn to the next non-eliminated participant in turn order,
# wrapping around, then opens their turn. Signals when the round is over
# instead: :last_player_standing or :deck_empty.
class AdvanceTurn
  def self.call(game)
    active = game.participants.active.by_turn_order.to_a
    return :last_player_standing if active.size <= 1

    current_order = game.current_participant.turn_order
    next_up = active.find { |p| p.turn_order > current_order } || active.first
    game.update!(current_participant: next_up)

    BeginTurn.call(game)
  end
end
