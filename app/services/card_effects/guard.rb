# frozen_string_literal: true

module CardEffects
  # Guard (1): name a non-Guard card; if the target holds it they are out.
  class Guard
    def self.call(target:, guess:, **)
      hit = target.holds?(guess)
      target.eliminate! if hit

      { guessed: guess, hit: hit }
    end
  end
end
