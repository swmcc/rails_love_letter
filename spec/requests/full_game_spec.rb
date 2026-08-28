# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Full game over HTTP', type: :request do
  def sign_in_and_join(name, game = nil)
    session = open_session
    session.post '/session', params: { name: name }
    if game
      session.post "/games/#{game.id}/join"
    else
      session.post '/games'
    end
    session
  end

  def play(session, game, card, target: nil, guess: nil)
    session.post "/games/#{game.id}/moves",
                 params: { card: card, target_id: target&.id, guess: guess }.compact
  end

  describe 'two players' do
    it 'plays rounds to overall victory: eliminations, showdown, tokens, game over' do
      alice_s = sign_in_and_join('Alice')
      game = Game.order(:id).last
      sign_in_and_join('Bob', game)

      alice_s.post "/games/#{game.id}/start"
      expect(game.reload).to be_in_round

      alice = game.participants.find_by(name: 'Alice')
      bob = game.participants.find_by(name: 'Bob')

      # Round 1 — Guard hit ends the round by elimination.
      rig_round!(game, hands: [%w[guard priest], %w[baron]], deck: %w[handmaid king], current: alice)
      play(alice_s, game, 'guard', target: bob, guess: 'baron')

      expect(bob.reload).to be_eliminated
      expect(game.reload).to be_round_over
      expect(alice.reload.tokens).to eq(1)
      expect(game.last_round_winner).to eq(alice)

      # Round 2 — the winner starts; deck runs dry and the showdown decides.
      alice_s.post "/games/#{game.id}/start"
      expect(game.reload.round_number).to eq(2)

      rig_round!(game, hands: [%w[handmaid princess], %w[guard]], deck: [], current: alice)
      play(alice_s, game, 'handmaid')

      expect(game.reload).to be_round_over
      expect(alice.reload.tokens).to eq(2) # Princess (8) beats Guard (1)

      # Round 3 — one token from the 2-player target of 7; winning ends the game.
      alice.update!(tokens: 6)
      alice_s.post "/games/#{game.id}/start"
      rig_round!(game, hands: [%w[guard priest], %w[baron]], deck: %w[king], current: alice)
      play(alice_s, game, 'guard', target: bob, guess: 'baron')

      expect(game.reload).to be_over
      expect(alice.reload.tokens).to eq(7)
      expect(game.finished_at).to be_present

      alice_s.get "/games/#{game.id}"
      expect(alice_s.response.body).to include('Game over')
    end
  end

  describe 'four players' do
    it 'skips eliminated players and enforces the forced Countess' do
      alice_s = sign_in_and_join('Alice')
      game = Game.order(:id).last
      bob_s = sign_in_and_join('Bob', game)
      cara_s = sign_in_and_join('Cara', game)
      dave_s = sign_in_and_join('Dave', game)

      alice_s.post "/games/#{game.id}/start"
      expect(game.reload).to be_in_round

      alice, bob, cara, dave = %w[Alice Bob Cara Dave].map { |n| game.participants.find_by(name: n) }

      rig_round!(game,
                 hands: [%w[guard priest], %w[baron], %w[handmaid], %w[king]],
                 deck: %w[guard prince countess guard], current: alice) # drawn from the end: Cara→guard, Dave→countess

      # Alice eliminates Bob; the turn must skip him and land on Cara.
      play(alice_s, game, 'guard', target: bob, guess: 'baron')
      expect(bob.reload).to be_eliminated
      expect(game.reload.current_participant).to eq(cara)

      # Cara protects herself; turn passes to Dave, who drew the Countess.
      play(cara_s, game, 'handmaid')
      expect(cara.reload.protected_until_turn).to be(true)
      expect(game.reload.current_participant).to eq(dave)
      expect(dave.reload.hand).to contain_exactly('king', 'countess')

      # Dave may not play the King while holding the Countess.
      play(dave_s, game, 'king', target: alice)
      expect(dave_s.response.status).to eq(302)
      dave_s.follow_redirect!
      expect(dave_s.response.body).to include('must play the Countess')

      play(dave_s, game, 'countess')
      expect(game.reload.current_participant).to eq(alice) # wrapped past eliminated Bob

      # Bob's session can no longer act.
      play(bob_s, game, 'baron', target: alice)
      bob_s.follow_redirect!
      expect(bob_s.response.body).to include('not your turn')
    end
  end
end
