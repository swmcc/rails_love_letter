class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :current_sid, :current_name

  def current_sid  = session[:sid]
  def current_name = session[:pname]

  def require_name!
    return if current_sid.present? && current_name.present?
    redirect_to new_session_path, alert: "Please enter your name to continue."
  end
end
