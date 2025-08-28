# frozen_string_literal: true

# app/controllers/games_controller.rb
class GamesController < ApplicationController
  before_action :require_name!

  def index
    @games = Game.order(created_at: :desc).limit(20)
  end

  def show
    @game = Game.find(params[:id])
    @participant = @game.participants.find_by(session_id: current_sid)

    # simple guard: show join button if not already joined
  end

  def create
    @game = Game.create!(max_players: 4)
    redirect_to @game
  end

  def join
    game = Game.find(params[:id])
    return redirect_to game, alert: I18nt.t('flash.games.already_started') unless game.joinable?

    game.participants.find_or_create_by!(session_id: current_sid) do |p|
      p.name = current_name
    end
    redirect_to game
  end

  def start
    game = Game.find(params[:id])
    return redirect_to game, alert: I18nt.t('flash.games.need_players') unless game.participants.size.between?(2, 4)

    game.start!
    redirect_to game, notice: I18nt.t('flash.games.started')
  end

  # optional: find by 6-char code
  def find_by_code
    @game = Game.find_by!(code: params[:code].to_s.upcase)
    redirect_to @game
  end
end
