# frozen_string_literal: true

module CardEffects
  # Handmaid (4): you cannot be targeted until the start of your next turn
  # (BeginTurn clears the flag).
  class Handmaid
    def self.call(actor:, **)
      actor.update!(protected_until_turn: true)

      { protected: true }
    end
  end
end
