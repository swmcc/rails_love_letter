# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Games', type: :request do
  before do
    post session_path, params: { name: 'Alice' }
  end

  describe 'POST /games/:id/join' do
    it 'renders an alert when the game has already started' do
      game = Game.create!(max_players: 4, started_at: Time.current)

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
  end
end
