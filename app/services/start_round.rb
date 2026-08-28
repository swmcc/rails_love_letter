# frozen_string_literal: true

# Starts a round: builds the shuffled deck, burns a card (plus three face-up
# cards in two-player games), deals one card to each participant and hands the
# first turn to the starter (round winner, or join order for round one).
class StartRound
  Error = Class.new(StandardError)

  def self.call(game, starter: nil) = new(game, starter:).call

  def initialize(game, starter: nil)
    @game = game
    @starter = starter
  end

  def call
    @game.with_lock do
      validate!
      deal_new_round!
      @game.transition_to!(:in_round)
    end
    @game
  end

  private

  def validate!
    raise Error, 'round already in progress' if @game.in_round?
    raise Error, 'game is over' if @game.over?
    raise Error, 'need 2-4 players' unless player_count.between?(2, 4)
  end

  def deal_new_round!
    deck = Card.deck.map { |card| card.key.to_s }.shuffle
    burned = deck.pop
    face_up = player_count == 2 ? deck.pop(3) : []

    reset_participants(deck)
    @game.update!(
      deck: deck, burned_card: burned, face_up_cards: face_up,
      round_number: @game.round_number + 1,
      current_participant: @starter || @game.participants.by_turn_order.first
    )
  end

  def player_count = @game.participants.count

  def reset_participants(deck)
    @game.participants.order(:id).each_with_index do |participant, index|
      participant.update!(
        turn_order: participant.turn_order || index,
        eliminated: false, protected_until_turn: false,
        discards: [], hand: [deck.pop]
      )
    end
  end
end
