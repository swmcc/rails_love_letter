# frozen_string_literal: true

module CardEffects
  # Princess (8): discarding her for any reason eliminates you. Voluntary
  # plays resolve here; the Prince's forced discard handles its own case.
  class Princess
    def self.call(actor:, **)
      actor.eliminate!

      { eliminated_id: actor.id }
    end
  end
end
