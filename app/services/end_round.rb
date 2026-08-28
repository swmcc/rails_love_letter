# frozen_string_literal: true

# Resolves the end of a round: picks the winner (last player standing, or
# the deck-empty showdown — highest card, then highest discard-value sum,
# then earliest turn order as a documented deterministic tiebreak), awards a
# favour token, records a round_end move with the revealed hands, and either
# closes the round or ends the game at the token target.
class EndRound
  TOKENS_TO_WIN = { 2 => 7, 3 => 5, 4 => 4 }.freeze

  def self.call(game, reason:) = new(game, reason).call

  def initialize(game, reason)
    @game = game
    @reason = reason
  end

  def call
    winner = round_winner
    winner.update!(tokens: winner.tokens + 1)
    record_round_end(winner)
    @game.transition_to!(:round_over)

    game_won = winner.tokens >= TOKENS_TO_WIN.fetch(@game.participants.count)
    @game.transition_to!(:over) if game_won

    { round_winner: winner, game_winner: game_won ? winner : nil }
  end

  private

  def round_winner
    contenders = @game.participants.active.by_turn_order.to_a
    return contenders.first if contenders.size == 1

    contenders.max_by { |p| [hand_value(p), discard_sum(p), -p.turn_order] }
  end

  def hand_value(participant)
    card = participant.hand.first
    card ? Card[card].value : 0
  end

  def discard_sum(participant)
    participant.discards.sum { |card| Card[card].value }
  end

  def record_round_end(winner)
    hands = @game.participants.active.to_h { |p| [p.id, p.hand.first] }
    @game.moves.create!(
      participant: winner,
      action: 'round_end',
      payload: { reason: @reason, winner_id: winner.id, hands: hands, round: @game.round_number }
    )
  end
end
