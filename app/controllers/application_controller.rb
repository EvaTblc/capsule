class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!, except: [:debug_auth]
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action do
    I18n.locale = :fr
  end

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern, if: -> { Rails.env.production? }

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :avatar])
  end

  def after_sign_in_path_for(user)
    stored_location_for(user) || collections_path
  end

  def default_url_options
    { host: ENV["DOMAIN"] || "localhost:3000" }
  end

  def debug_auth
    render json: {
      signed_in: user_signed_in?,
      current_user_id: current_user&.id,
      current_user_email: current_user&.email,
      session_keys: session.keys,
      warden_user: warden.user&.id,
      session_id: session.id&.to_s,
      user_id_in_session: session[:user_id]
    }
  end
end
