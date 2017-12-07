require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Tomato
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.time_zone = 'Amsterdam'

    config.i18n.default_locale = :nl
    config.i18n.available_locales = %i[en nl]
    config.i18n.fallbacks = [:en]

    config.x.banana_host_url = ENV['BANANA_HOST_URL']
  end
end
