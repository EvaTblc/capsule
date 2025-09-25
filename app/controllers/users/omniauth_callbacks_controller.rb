# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: [:passthru, :google_oauth2, :failure]
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
  # Prevent duplicate processing
  return if performed?

  # Check if user is already signed in from a previous successful request
  if user_signed_in?
    redirect_to after_sign_in_path_for(current_user)
    return
  end

  # First try to find existing user
  user = User.find_by(provider: auth.provider, uid: auth.uid)

  # If not found, create new user
  if user.nil?
    user = User.from_omniauth(auth)
  end

  if user.present? && user.persisted?
    # Clear any existing sessions to prevent conflicts
    reset_session
    sign_in(user, event: :authentication)
    redirect_to after_sign_in_path_for(user)
    set_flash_message(:notice, :success, kind: 'Google') if is_navigational_format?
  else
    # Only redirect to registration if the user creation actually failed
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
