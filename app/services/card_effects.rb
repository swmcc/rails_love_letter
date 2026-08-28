# frozen_string_literal: true

# Registry mapping card keys to effect resolvers. Resolvers are callables
# receiving (game:, actor:, target:, guess:) and returning an outcome hash
# that is stored on the Move's payload. Cards without a registered resolver
# discard with no effect.
module CardEffects
  @resolvers = {}

  class << self
    def register(key, resolver)
      @resolvers[key.to_sym] = resolver
    end

    def resolve(card:, game:, actor:, target: nil, guess: nil)
      resolver = @resolvers[card.key]
      return {} unless resolver

      resolver.call(game: game, actor: actor, target: target, guess: guess)
    end
  end
end
