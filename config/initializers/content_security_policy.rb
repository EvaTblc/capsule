# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

# Rails.application.configure do
#   config.content_security_policy do |policy|
#     policy.default_src :self, :https
#     policy.font_src    :self, :https, :data
#     policy.img_src     :self, :https, :data
#     policy.object_src  :none
#     policy.script_src  :self, :https
#     policy.style_src   :self, :https
#     # Specify URI for violation reports
#     # policy.report_uri "/csp-violation-report-endpoint"
#   end
#
#   # Generate session nonces for permitted importmap, inline scripts, and inline styles.
#   config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
#   config.content_security_policy_nonce_directives = %w(script-src style-src)
#
#   # Report violations without enforcing the policy.
#   # config.content_security_policy_report_only = true
# end

Rails.application.configure do
  config.content_security_policy do |p|
    p.default_src :self
    p.script_src  :self, "https://cdn.jsdelivr.net", "https://ga.jspm.io"
    p.connect_src :self, "https://cdn.jsdelivr.net", "https://ga.jspm.io"
    p.img_src     :self, :data, :blob, :https, "res.cloudinary.com"
    p.media_src   :self, :blob
    p.style_src   :self, :unsafe_inline, "https://fonts.googleapis.com"
    p.font_src    :self, :data, "https://fonts.gstatic.com"
    p.worker_src  :self, :blob
    p.frame_ancestors :self, "https://accounts.google.com"
    p.object_src  :none
    p.base_uri    :self
  end

  # ✅ indispensable pour l’importmap inline
  config.content_security_policy_nonce_generator  = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
  config.permissions_policy do |p|
    p.camera :self
  end
end
