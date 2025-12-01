require './app/models/sofia_account'

Devise.setup do |config|
  config.secret_key = Rails.application.secret_key_base
  config.mailer_sender = Rails.application.config.x.ict_email

  # ==> ORM configuration
  require 'devise/orm/active_record'

  config.sign_out_via = :delete

  # ==> OmniAuth
  require_dependency Rails.root.join('config', 'initializers', 'omniauth_strategies', 'amber_oauth2.rb')

  config.omniauth :amber_oauth2, Rails.application.config.x.amber_client_id,
                  Rails.application.config.x.amber_client_secret
  config.omniauth :identity, model: SofiaAccount, fields: %i[username user_id],
                             locate_conditions: ->(req) { { SofiaAccount.auth_key => req.params['auth_key'] } },
                             on_login: lambda { |e|
                                         SofiaAccountsController.action(:omniauth_redirect_login).call(e)
                                       },
                             on_registration: lambda { |e|
                                                SofiaAccountsController.action(:omniauth_redirect_register).call(e)
                                              }

  # TODO: EW
  # OmniAuth.config.on_failure = Proc.new { |env|
  #   OmniAuth::FailureEndpoint.new(env).redirect_to_failure
  # }
end
