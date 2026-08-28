# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Turn engine' do
  def started_game(players: 3)
    game = Game.create!
    players.times { |i| game.participants.create!(name: "P#{i}", session_id: "s#{i}") }
    StartRound.call(game)
  end

  describe BeginTurn do
    it 'draws the top deck card into the current hand' do
      game = started_game
      game.update!(current_participant: game.participants.by_turn_order.second)
      top = game.deck.last
      deck_size = game.deck.size

      result = described_class.call(game)

      expect(result).to eq(:drew)
      expect(game.current_participant.hand).to include(top)
      expect(game.reload.deck.size).to eq(deck_size - 1)
    end

    it 'clears Handmaid protection at the start of your own turn' do
      game = started_game
      game.current_participant.update!(protected_until_turn: true)

      described_class.call(game)

      expect(game.current_participant.reload.protected_until_turn).to be(false)
    end

    it 'signals when the deck is empty instead of drawing' do
      game = started_game
      game.update!(deck: [])

      expect(described_class.call(game)).to eq(:deck_empty)
    end
  end

  describe AdvanceTurn do
    it 'advances to the next player in turn order and draws for them' do
      game = started_game(players: 3)
      second = game.participants.by_turn_order.second
      before_size = second.hand.size

      described_class.call(game)

      expect(game.current_participant).to eq(second)
      expect(second.reload.hand.size).to eq(before_size + 1)
    end

    it 'skips eliminated players and wraps around the order' do
      game = started_game(players: 3)
      first, second, third = game.participants.by_turn_order.to_a
      game.update!(current_participant: third)
      second.update!(eliminated: true)

      described_class.call(game)

      expect(game.current_participant).to eq(first)

      game.update!(current_participant: first)
      described_class.call(game)
      expect(game.current_participant).to eq(third)
    end

    it 'signals last player standing instead of advancing' do
      game = started_game(players: 3)
      game.participants.by_turn_order.to_a[1..].each { |p| p.update!(eliminated: true) }

      expect(described_class.call(game)).to eq(:last_player_standing)
    end

    it 'signals an empty deck via BeginTurn' do
      game = started_game(players: 3)
      game.update!(deck: [])

      expect(described_class.call(game)).to eq(:deck_empty)
    end
  end
end
