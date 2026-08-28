# frozen_string_literal: true

# Dispatches a played card to its effect resolver (CardEffects::Guard etc.).
# Resolvers receive (game:, actor:, target:, guess:) and return an outcome
# hash stored on the Move's payload. Cards without a resolver discard with
# no effect.
module CardEffects
  def self.resolve(card:, game:, actor:, target: nil, guess: nil)
    name = card.key.to_s.camelize
    return {} unless const_defined?(name, false)

    const_get(name, false).call(game: game, actor: actor, target: target, guess: guess)
  end
end
