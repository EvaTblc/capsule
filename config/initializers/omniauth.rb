# Basic OmniAuth configuration
OmniAuth.config.allowed_request_methods = [:get, :post]
OmniAuth.config.silence_get_warning = true

# Simple monkey patch to disable CSRF validation
Rails.application.config.to_prepare do
  require 'omniauth/strategies/oauth2'

  # Patch the OAuth2 strategy to skip CSRF validation
  OmniAuth::Strategies::OAuth2.class_eval do
    def callback_phase
      # Get the authorization code from Google
      code = request.params['code']

      # Build access token without CSRF validation
      @access_token = client.auth_code.get_token(
        code,
        {:redirect_uri => callback_url},
        deep_symbolize(options.auth_token_params)
      )

      # Continue with normal flow
      super
    rescue ::OAuth2::Error, ::Timeout::Error, ::Errno::ETIMEDOUT, ::SocketError => e
      fail!(e.code, e)
    end
  end
end