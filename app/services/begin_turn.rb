# frozen_string_literal: true

# Opens the current participant's turn: Handmaid protection expires at the
# start of your own turn, then you draw the top card of the deck. An empty
# deck means the round ends instead (resolved by EndRound).
class BeginTurn
  def self.call(game)
    participant = game.current_participant
    participant.update!(protected_until_turn: false) if participant.protected_until_turn?

    return :deck_empty if game.deck.empty?

    deck = game.deck.dup
    participant.update!(hand: participant.hand + [deck.pop])
    game.update!(deck: deck)
    :drew
  end
end
