Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas, url: Settings.cas_url, on_single_sign_out: true
end
