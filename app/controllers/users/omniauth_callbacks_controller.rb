# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token
  protect_from_forgery except: :google_oauth2
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  # GET|POST /resource/auth/twitter
  def passthru
    super
  end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

def google_oauth2
  Rails.logger.info "=== OAuth Callback Debug ==="
  Rails.logger.info "Auth object present: #{auth.present?}"
  Rails.logger.info "Auth info: #{auth.info.email rescue 'N/A'}"

  user = User.from_omniauth(auth)
  Rails.logger.info "User found: #{user.present?}"
  Rails.logger.info "User persisted: #{user&.persisted?}"

  if user.present? && user.persisted?
    Rails.logger.info "Attempting sign in for user: #{user.email}"

    # Force session persistence before sign in
    session[:user_id] = user.id
    warden.set_user(user, scope: :user, store: true)

    Rails.logger.info "User signed in: #{user_signed_in?}"
    Rails.logger.info "Current user: #{current_user&.email}"

    # Directly redirect to collections instead of using after_sign_in_path_for
    redirect_to collections_path, notice: "Connecté avec succès via Google!"
  else
    Rails.logger.info "User creation failed or not found"
    session[:omniauth_auth] = auth.except('extra')
    flash[:alert] = "Veuillez compléter votre inscription"
    redirect_to new_user_registration_path
  end
end


  def failure
    redirect_to root_path, alert: "Échec de l’authentification"
  end
  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
  #
  private

  def auth
    @auth ||= request.env['omniauth.auth']
  end
end
