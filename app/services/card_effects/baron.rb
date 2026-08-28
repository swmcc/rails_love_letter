# frozen_string_literal: true

module CardEffects
  # Baron (3): compare hands; the lower value is out, ties do nothing.
  # Both cards are recorded as visible to the two players involved — the
  # loser's card becomes public through their discard pile anyway.
  class Baron
    def self.call(actor:, target:, **)
      actor_card = actor.hand.first
      target_card = target.hand.first
      loser = loser_between(actor, target, actor_card, target_card)
      loser&.eliminate!

      { actor_card: actor_card, target_card: target_card,
        loser_id: loser&.id, visible_to: [actor.id, target.id] }
    end

    def self.loser_between(actor, target, actor_card, target_card)
      case Card[actor_card].value <=> Card[target_card].value
      when -1 then actor
      when 1 then target
      end
    end
  end
end
