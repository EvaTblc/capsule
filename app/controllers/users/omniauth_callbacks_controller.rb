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
  user = User.from_omniauth(auth)

  if user.present? && user.persisted?
    sign_in_and_redirect user, event: :authentication
    set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
  else
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
