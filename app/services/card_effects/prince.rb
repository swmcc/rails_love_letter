# frozen_string_literal: true

module CardEffects
  # Prince (5): the target (possibly the actor) discards their hand without
  # effect — except the Princess, which eliminates them — and draws a new
  # card, from the burned card if the deck is empty.
  class Prince
    def self.call(game:, target:, **)
      discarded = target.hand.first

      if discarded == 'princess'
        target.eliminate!
        return { discarded: 'princess', eliminated_id: target.id }
      end

      target.update!(hand: [], discards: target.discards + [discarded])
      replacement = next_card(game)
      target.update!(hand: [replacement]) if replacement

      { discarded: discarded, drew: replacement.present? }
    end

    def self.next_card(game)
      if game.deck.any?
        deck = game.deck.dup
        card = deck.pop
        game.update!(deck: deck)
        card
      else
        game.burned_card.tap { game.update!(burned_card: nil) }
      end
    end
  end
end
