require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'carrierwave'
require 'carrierwave/orm/activerecord'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dome
  class Application < Rails::Application
    config.load_paths << "#{Rails.root}/app/uploaders"
    config.time_zone = 'Asia/Shanghai'
    config.active_record.default_timezone = :local
    config.i18n.default_locale = 'zh-CN'
    config.encoding = 'utf-8'
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
