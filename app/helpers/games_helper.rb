# frozen_string_literal: true

module GamesHelper
  def card_label(key)
    card = key && Card[key]
    card ? "#{card.name} (#{card.value})" : '—'
  end

  # Players the given participant could target with a card right now.
  def targetable_players(game, actor, card_key)
    card = Card[card_key]
    return [] unless card&.requires_target?

    targets = game.participants.active.where(protected_until_turn: false)
    targets = targets.where.not(id: actor.id) unless card.can_target_self?
    targets.by_turn_order
  end

  # One line of the move log, hiding private reveals from other viewers.
  def describe_move(move, viewer:)
    return round_end_summary(move) if move.action == 'round_end'

    payload = move.payload || {}
    [play_line(move, payload), outcome_summary(payload['outcome'] || {}, move, viewer)].compact.join(' ')
  end

  private

  def play_line(move, payload)
    line = "#{move.participant.name} played #{card_label(payload['card'])}"
    line += " against #{move.game.participants.find(payload['target_id']).name}" if payload['target_id']
    line += " guessing #{card_label(payload['guess'])}" if payload['guess']
    line
  end

  def round_end_summary(move)
    reason = move.payload['reason'] == 'deck_empty' ? 'the deck ran out' : 'they were the last player standing'
    "Round #{move.payload['round']}: #{move.participant.name} won — #{reason}."
  end

  def outcome_summary(outcome, move, viewer)
    guard_note(outcome) || private_reveal(outcome, viewer) ||
      baron_summary(outcome, move) || misc_note(outcome, move)
  end

  def guard_note(outcome)
    return '— no effect (no valid target)' if outcome['no_effect']

    "— #{outcome['hit'] ? 'hit! They are out.' : 'miss.'}" if outcome.key?('hit')
  end

  def misc_note(outcome, move)
    return '— they are protected until their next turn' if outcome['protected']
    return "— they discarded #{card_label(outcome['discarded'])}" if outcome['discarded']
    return '— they swapped hands' if outcome['swapped_with']

    "— #{move.participant.name} is out!" if outcome['eliminated_id'] == move.participant.id
  end

  def private_reveal(outcome, viewer)
    return if outcome['revealed_card'].nil?
    return '— looked at their hand' unless viewer && outcome['visible_to']&.include?(viewer.id)

    "— you saw #{card_label(outcome['revealed_card'])}"
  end

  def baron_summary(outcome, move)
    return unless outcome.key?('loser_id')
    return '— tie, nothing happens' if outcome['loser_id'].nil?

    "— #{move.game.participants.find(outcome['loser_id']).name} had the lower card and is out"
  end
end
