Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
        'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = {host: 'localhost', port: 3000}
  config.host_url = "http://localhost:3000/"
  config.staticfile_server_url = "http://localhost:3000/"
  config.action_mailer.delivery_method = :smtp
  ActionMailer::Base.default :from => Settings.email_form

  config.action_mailer.smtp_settings = {

      :address => Settings.smtp_address,
      :user_name => Settings.email_username,
      :password => Settings.email_password,
      :port => 25,
      :domain => Settings.smtp_domain,
      :authentication => :login,
      :enable_starttls_auto => true}

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Set Action Cable server url for consumer connection
  config.action_cable.url = '/cable'
  config.action_cable.allowed_request_origins = ['http://dev.robodou.com', 'http://localhost:3002']

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end
