Devise.setup do |config|
  config.mailer_sender = 'ict@csvalpha.nl'

  # ==> ORM configuration
  require 'devise/orm/active_record'

  config.sign_out_via = :delete

  # ==> OmniAuth
  require 'omniauth_strategies'

  # config.omniauth :banana_oauth2, Rails.application.secrets.fetch(:banana_app_id),
  #                 Rails.application.secrets.fetch(:banana_app_secret)

  config.omniauth :google_oauth2, Rails.application.secrets.fetch(:google_client_id),
                  Rails.application.secrets.fetch(:google_client_secret)
end
