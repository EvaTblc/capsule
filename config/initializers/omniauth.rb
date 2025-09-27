Rails.application.config.to_prepare do
  # Configure OmniAuth to allow GET and POST requests
  OmniAuth.config.allowed_request_methods = [ :get, :post ]
  OmniAuth.config.silence_get_warning = true

  # Let Devise handle CSRF protection
  OmniAuth.config.request_validation_phase = nil
end
