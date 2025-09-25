Rails.application.config.to_prepare do
  # Configure OmniAuth to allow GET and POST requests
  OmniAuth.config.allowed_request_methods = [:get, :post]
  OmniAuth.config.silence_get_warning = true

  # Proper CSRF protection configuration
  OmniAuth.config.request_validation_phase = OmniAuth::AuthenticityTokenProtection.new
end