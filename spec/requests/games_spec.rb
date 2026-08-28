# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Games', type: :request do
  before do
    post session_path, params: { name: 'Alice' }
  end

  def my_session_id
    Participant.order(:id).last&.session_id
  end

  describe 'POST /games' do
    it 'creates a game with the creator already joined as host' do
      post games_path
      game = Game.order(:id).last

      expect(game.participants.count).to eq(1)
      expect(game.participants.first.name).to eq('Alice')
      expect(game.host).to eq(game.participants.first)
    end
  end

  describe 'POST /games/:id/join' do
    it 'renders an alert when the game has already started' do
      game = Game.create!(max_players: 4, state: 'in_round', started_at: Time.current)

      post join_game_path(game)
      follow_redirect!

      expect(response.body).to include('Game already started.')
    end
  end

  describe 'POST /games/:id/start' do
    it 'renders an alert when the game has fewer than two players' do
      game = Game.create!(max_players: 4)

      post start_game_path(game)
      follow_redirect!

      expect(response.body).to include('Need 2-4 players.')
    end

    it 'refuses to let a non-host start the game' do
      post games_path
      game = Game.order(:id).last
      game.participants.create!(name: 'Zed', session_id: 'zed-sid')
      host = game.participants.order(:id).first
      host.update!(session_id: 'someone-else') # the request session is no longer host

      post start_game_path(game)
      follow_redirect!

      expect(response.body).to include('Only the host')
      expect(game.reload).to be_lobby
    end

    it 'lets the host start and only the round winner start the next round' do
      post games_path
      game = Game.order(:id).last
      game.participants.create!(name: 'Bob', session_id: 'bob-sid')

      post start_game_path(game)
      expect(game.reload).to be_in_round

      # end the round with Bob as winner, then Alice may not restart
      game.participants.find_by(name: 'Alice').update!(eliminated: true)
      EndRound.call(game, reason: :last_player_standing)

      post start_game_path(game)
      follow_redirect!
      expect(response.body).to include('Only the host')
      expect(game.reload).to be_round_over
    end
  end

  describe 'POST /games/:id/rematch' do
    it 'creates a fresh game with the same players pre-joined' do
      post games_path
      game = Game.order(:id).last
      game.participants.create!(name: 'Bob', session_id: 'bob-sid')
      game.update!(state: 'over', finished_at: Time.current)

      post rematch_game_path(game)
      new_game = Game.order(:id).last

      expect(new_game).not_to eq(game)
      expect(new_game).to be_lobby
      expect(new_game.participants.pluck(:name)).to contain_exactly('Alice', 'Bob')
    end

    it 'refuses a rematch while the game is running' do
      game = Game.create!(state: 'in_round')

      expect { post rematch_game_path(game) }.not_to change(Game, :count)
    end
  end

  describe 'GET /games/code' do
    it 'redirects to the game for a known code' do
      game = Game.create!(code: 'ABC123')

      get code_games_path, params: { code: 'abc123' }

      expect(response).to redirect_to(game_path(game))
    end

    it 'returns to the lobby with an alert for an unknown code' do
      get code_games_path, params: { code: 'NOPE99' }
      follow_redirect!

      expect(response.body).to include('No game with that code.')
    end
  end
end
