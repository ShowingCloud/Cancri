Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas, url: Settings.cas_url
end
