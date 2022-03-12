Devise.setup do |config|
  config.mailer_sender = 'ict@csvalpha.nl'

  # ==> ORM configuration
  require 'devise/orm/active_record'

  config.sign_out_via = :delete

  # ==> OmniAuth
  require 'omniauth_strategies'

  config.omniauth :amber_oauth2, Rails.application.config.x.amber_client_id,
                  Rails.application.config.x.amber_client_secret
end
