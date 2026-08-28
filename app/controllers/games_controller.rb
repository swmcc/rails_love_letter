# frozen_string_literal: true

class GamesController < ApplicationController
  before_action :require_name!

  def index
    @games = Game.lobby.order(created_at: :desc).limit(20)
  end

  def show
    @game = Game.find(params[:id])
    @participant = @game.participants.find_by(session_id: current_sid)
  end

  def create
    game = Game.create!(max_players: 4)
    game.participants.create!(session_id: current_sid, name: current_name)
    redirect_to game
  end

  def join
    game = Game.find(params[:id])
    return redirect_to game, alert: I18n.t('flash.games.already_started') unless game.joinable?

    game.participants.find_or_create_by!(session_id: current_sid) do |p|
      p.name = current_name
    end
    redirect_to game
  end

  def start
    game = Game.find(params[:id])
    blocker = start_blocker(game)
    return redirect_to game, alert: blocker if blocker

    StartRound.call(game, starter: game.round_over? ? game.last_round_winner : nil)
    redirect_to game, notice: I18n.t('flash.games.started')
  rescue StartRound::Error
    redirect_to game, alert: I18n.t('flash.games.cannot_start')
  end

  def rematch
    game = Game.find(params[:id])
    return redirect_to game, alert: I18n.t('flash.games.not_finished') unless game.over?

    redirect_to rematch_of(game), notice: I18n.t('flash.games.rematch')
  end

  def find_by_code
    game = Game.find_by(code: params[:code].to_s.strip.upcase)
    return redirect_to games_path, alert: I18n.t('flash.games.unknown_code') if game.nil?

    redirect_to game
  end

  private

  def start_blocker(game)
    return I18n.t('flash.games.need_players') unless game.participants.size.between?(2, 4)

    I18n.t('flash.games.not_your_start') unless may_start?(game)
  end

  def rematch_of(game)
    new_game = Game.create!(max_players: game.max_players)
    game.participants.order(:id).each do |p|
      new_game.participants.create!(session_id: p.session_id, name: p.name)
    end
    new_game
  end

  # In the lobby only the host may start; between rounds only the winner.
  def may_start?(game)
    me = game.participants.find_by(session_id: current_sid)
    return false if me.nil?
    return me == game.last_round_winner if game.round_over?

    me == game.host
  end
end
