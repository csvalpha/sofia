Devise.setup do |config|
  config.secret_key = Rails.application.secret_key_base
  config.mailer_sender = Rails.application.config.x.ict_email

  # ==> ORM configuration
  require 'devise/orm/active_record'

  config.sign_out_via = :delete

  # ==> OmniAuth
  require_dependency Rails.root.join('config', 'initializers', 'omniauth_strategies', 'amber_oauth2.rb', 'amber_oauth2.rb',
                                     'omniauth_strategies', 'amber_oauth2.rb', 'amber_oauth2.rb')

  config.omniauth :amber_oauth2, Rails.application.config.x.amber_client_id,
                  Rails.application.config.x.amber_client_secret
end
