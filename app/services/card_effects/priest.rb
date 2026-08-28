# frozen_string_literal: true

module CardEffects
  # Priest (2): privately look at the target's hand. The revealed card is
  # recorded with who may see it; render-time code must only show it to them.
  class Priest
    def self.call(actor:, target:, **)
      { revealed_card: target.hand.first, visible_to: [actor.id] }
    end
  end
end
