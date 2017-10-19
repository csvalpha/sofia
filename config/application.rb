require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Tomato
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.i18n.default_locale = :nl
    config.i18n.available_locales = %i[en nl]
  end
end
