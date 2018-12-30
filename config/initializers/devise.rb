Devise.setup do |config|
  config.mailer_sender = 'ict@csvalpha.nl'

  # ==> ORM configuration
  require 'devise/orm/active_record'

  config.sign_out_via = :delete

  # ==> OmniAuth
  require 'omniauth_strategies'

  config.omniauth :banana_oauth2, Rails.application.credentials.dig(Rails.env.to_sym, :banana_client_id),
                  Rails.application.credentials.dig(Rails.env.to_sym, :banana_client_secret)
end
