# frozen_string_literal: true

module CardEffects
  # King (6): trade hands with the target.
  class King
    def self.call(actor:, target:, **)
      actor_hand = actor.hand
      actor.update!(hand: target.hand)
      target.update!(hand: actor_hand)

      { swapped_with: target.id }
    end
  end
end
