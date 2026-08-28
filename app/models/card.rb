# frozen_string_literal: true

class Card
  include Comparable

  attr_reader :key, :name, :value, :count_in_deck, :effect

  def initialize(key:, name:, value:, count_in_deck:, effect:, requires_target:, can_target_self:, requires_guess:) # rubocop:disable Metrics/ParameterLists
    @key = key
    @name = name.freeze
    @value = value
    @count_in_deck = count_in_deck
    @effect = effect.freeze
    @requires_target = requires_target
    @can_target_self = can_target_self
    @requires_guess = requires_guess
    freeze
  end # rubocop:enable Metrics/ParameterLists

  def <=>(other)
    value <=> other.value if other.respond_to?(:value)
  end

  def requires_target? = @requires_target
  def can_target_self? = @can_target_self
  def requires_guess? = @requires_guess

  CARDS = [
    new(key: :guard, name: 'Guard', value: 1, count_in_deck: 5,
        effect: 'Choose another player and name a non-Guard card. If they hold that card, they are out of the round.',
        requires_target: true, can_target_self: false, requires_guess: true),
    new(key: :priest, name: 'Priest', value: 2, count_in_deck: 2,
        effect: "Look at another player's hand.",
        requires_target: true, can_target_self: false, requires_guess: false),
    new(key: :baron, name: 'Baron', value: 3, count_in_deck: 2,
        effect: 'Compare hands with another player. The player with the lower-value card is out of the round.',
        requires_target: true, can_target_self: false, requires_guess: false),
    new(key: :handmaid, name: 'Handmaid', value: 4, count_in_deck: 2,
        effect: 'Until your next turn, other players cannot choose you for a card effect.',
        requires_target: false, can_target_self: false, requires_guess: false),
    new(key: :prince, name: 'Prince', value: 5, count_in_deck: 2,
        effect: 'Choose any player, including yourself. They discard their hand and draw a new card.',
        requires_target: true, can_target_self: true, requires_guess: false),
    new(key: :king, name: 'King', value: 6, count_in_deck: 1,
        effect: 'Trade hands with another player.',
        requires_target: true, can_target_self: false, requires_guess: false),
    new(key: :countess, name: 'Countess', value: 7, count_in_deck: 1,
        effect: 'You must play this card if the other card in your hand is the King or a Prince.',
        requires_target: false, can_target_self: false, requires_guess: false),
    new(key: :princess, name: 'Princess', value: 8, count_in_deck: 1,
        effect: 'If you discard this card, you are out of the round.',
        requires_target: false, can_target_self: false, requires_guess: false)
  ].freeze

  INDEX = CARDS.to_h { |card| [card.key, card] }.freeze # rubocop:disable Rails/IndexBy -- Keep this PORO dependency-free.
  DECK = CARDS.flat_map { |card| [card] * card.count_in_deck }.freeze

  private_constant :CARDS, :INDEX, :DECK

  class << self
    def all = CARDS
    def [](key) = INDEX[key.to_sym]
    def deck = DECK
  end
end
