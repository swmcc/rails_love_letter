# frozen_string_literal: true

class Card
  include Comparable

  attr_reader :key, :name, :value, :count_in_deck, :effect

  def self.all = ALL
  def self.deck = DECK

  def self.[](key)
    BY_KEY[key.to_sym]
  end

  def initialize(key:, name:, value:, count_in_deck:, effect:, requires_target:, can_target_self:, requires_guess:)
    @key = key
    @name = name
    @value = value
    @count_in_deck = count_in_deck
    @effect = effect
    @requires_target = requires_target
    @can_target_self = can_target_self
    @requires_guess = requires_guess

    freeze
  end

  def <=>(other)
    return unless other.respond_to?(:value)

    value <=> other.value
  end

  def requires_target? = @requires_target
  def can_target_self? = @can_target_self
  def requires_guess? = @requires_guess

  ALL = [
    new(
      key: :guard,
      name: 'Guard',
      value: 1,
      count_in_deck: 5,
      effect: "Guess a non-Guard card in another player's hand; they are out if correct.",
      requires_target: true,
      can_target_self: false,
      requires_guess: true
    ),
    new(
      key: :priest,
      name: 'Priest',
      value: 2,
      count_in_deck: 2,
      effect: "Look at another player's hand.",
      requires_target: true,
      can_target_self: false,
      requires_guess: false
    ),
    new(
      key: :baron,
      name: 'Baron',
      value: 3,
      count_in_deck: 2,
      effect: 'Compare hands with another player; lower value is out.',
      requires_target: true,
      can_target_self: false,
      requires_guess: false
    ),
    new(
      key: :handmaid,
      name: 'Handmaid',
      value: 4,
      count_in_deck: 2,
      effect: 'You cannot be targeted by other card effects until your next turn.',
      requires_target: false,
      can_target_self: false,
      requires_guess: false
    ),
    new(
      key: :prince,
      name: 'Prince',
      value: 5,
      count_in_deck: 2,
      effect: 'Choose any player, including yourself, to discard their hand and draw a new card.',
      requires_target: true,
      can_target_self: true,
      requires_guess: false
    ),
    new(
      key: :king,
      name: 'King',
      value: 6,
      count_in_deck: 1,
      effect: 'Trade hands with another player.',
      requires_target: true,
      can_target_self: false,
      requires_guess: false
    ),
    new(
      key: :countess,
      name: 'Countess',
      value: 7,
      count_in_deck: 1,
      effect: 'Must be played if your other card is the King or Prince.',
      requires_target: false,
      can_target_self: false,
      requires_guess: false
    ),
    new(
      key: :princess,
      name: 'Princess',
      value: 8,
      count_in_deck: 1,
      effect: 'You are out if you discard this card.',
      requires_target: false,
      can_target_self: false,
      requires_guess: false
    )
  ].freeze

  BY_KEY = ALL.to_h { |card| [card.key, card] }.freeze
  DECK = ALL.flat_map { |card| [card] * card.count_in_deck }.freeze
end
