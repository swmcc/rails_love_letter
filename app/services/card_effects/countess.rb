# frozen_string_literal: true

module CardEffects
  # Countess (7): no effect when played. The forced-play rule (must be
  # played while holding the King or Prince) lives in PlayCard's validation.
  class Countess
    def self.call(**)
      {}
    end
  end
end
