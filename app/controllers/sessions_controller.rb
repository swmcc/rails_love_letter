# frozen_string_literal: true

class SessionsController < ApplicationController
  def new; end

  def create
    session[:sid] ||= SecureRandom.uuid
    session[:pname] = params.require(:name).to_s.strip
    redirect_to root_path, notice: I18n.t('flash.sessions.welcome', name: session[:pname])
  end

  def destroy
    reset_session
    redirect_to new_session_path, notice: I18n.t('flash.sessions.goodbye')
  end
end
