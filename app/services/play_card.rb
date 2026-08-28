# frozen_string_literal: true

# The single entry point for taking a turn: validates the play (turn,
# ownership, targeting, the forced-Countess rule), discards the card,
# resolves its effect, records the Move and advances the turn.
#
# When every possible target is protected or eliminated, a targeted card may
# be played with no effect — it is still discarded (official rule).
class PlayCard
  Error = Class.new(StandardError)
  Result = Struct.new(:move, :turn_signal, keyword_init: true)

  def self.call(game:, participant:, card:, target: nil, guess: nil)
    new(game:, participant:, card:, target:, guess:).call
  end

  def initialize(game:, participant:, card:, target: nil, guess: nil)
    @game = game
    @actor = participant
    @card_key = card.to_s
    @target = target
    @guess = guess&.to_s
  end

  def call
    @game.with_lock do
      validate!
      discard_from_hand!
      outcome = @no_effect ? { no_effect: true } : resolve_effect
      move = record_move(outcome)
      signal = AdvanceTurn.call(@game)
      EndRound.call(@game, reason: signal) unless signal == :drew
      Result.new(move: move, turn_signal: signal)
    end
  end

  private

  def card_def
    @card_def ||= Card[@card_key] || raise(Error, 'Unknown card.')
  end

  def validate!
    raise Error, 'The round is not in progress.' unless @game.in_round?
    raise Error, 'It is not your turn.' unless @actor == @game.current_participant
    raise Error, 'You do not hold that card.' unless @actor.holds?(card_def.key)

    validate_countess_rule!
    validate_target!
    validate_guess!
  end

  def validate_countess_rule!
    return unless %w[king prince].include?(@card_key) && @actor.holds?(:countess)

    raise Error, 'You must play the Countess while holding the King or Prince.'
  end

  def validate_target!
    return unless card_def.requires_target?

    if valid_targets.empty?
      @no_effect = true
      @target = nil
      return
    end

    raise Error, 'Choose a player to target.' if @target.nil?
    raise Error, 'That player cannot be targeted.' unless valid_targets.include?(@target)
  end

  def validate_guess!
    return unless card_def.requires_guess? && !@no_effect

    raise Error, 'Name a card to guess.' if @guess.blank?
    raise Error, 'Unknown card.' if Card[@guess].nil?
    raise Error, 'You cannot guess the Guard.' if @guess == 'guard'
  end

  def valid_targets
    @valid_targets ||= begin
      targets = @game.participants.active.where(protected_until_turn: false)
      targets = targets.where.not(id: @actor.id) unless card_def.can_target_self?
      targets.to_a
    end
  end

  def discard_from_hand!
    hand = @actor.hand.dup
    hand.delete_at(hand.index(@card_key))
    @actor.update!(hand: hand, discards: @actor.discards + [@card_key])
  end

  def resolve_effect
    CardEffects.resolve(card: card_def, game: @game, actor: @actor, target: @target, guess: @guess)
  end

  def record_move(outcome)
    @game.moves.create!(
      participant: @actor,
      action: 'play',
      payload: {
        card: @card_key, target_id: @target&.id, guess: @guess, outcome: outcome
      }.compact
    )
  end
end
