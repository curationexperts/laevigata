require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
module Laevigata
  class Application < Rails::Application
    config.action_mailer.default_url_options = { host: ENV["RAILS_HOST"] }
    config.action_mailer.raise_delivery_errors = false
    config.i18n.default_locale = :en
    config.i18n.enforce_available_locales = false
    # The compile method (default in tinymce-rails 4.5.2) doesn't work when also
    # using tinymce-rails-imageupload, so revert to the :copy method
    # https://github.com/spohlenz/tinymce-rails/issues/183
    config.tinymce.install = :copy
    config.generators do |g|
      g.test_framework :rspec, spec: true
    end
    config.active_job.queue_adapter = :sidekiq
    config.autoload_paths += %W[#{config.root}/lib]
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
Rails.application.routes.default_url_options[:host] = ENV["RAILS_HOST"]
