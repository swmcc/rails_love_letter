# frozen_string_literal: true

class MovesController < ApplicationController
  before_action :require_name!

  def create
    game = Game.find(params[:game_id])
    participant = game.participants.find_by!(session_id: current_sid)

    PlayCard.call(game:, participant:, card: params[:card], target: target_for(game), guess: params[:guess])
    redirect_to game
  rescue PlayCard::Error => e
    redirect_to game, alert: e.message
  end

  private

  def target_for(game)
    return if params[:target_id].blank?

    game.participants.find(params[:target_id])
  end
end
