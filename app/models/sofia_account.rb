class SofiaAccount < OmniAuth::Identity::Models::ActiveRecord
  has_one_time_password

  belongs_to :user

  validates :user, uniqueness: true
  validates :username, presence: true, uniqueness: true
  validates :password, length: { minimum: 12 }, allow_nil: true # the presence of :password is already checked by omniauth-sofia-account itself

  auth_key :username    # specifies the field within the model that will be used during the login process as username

  def self.activate_account_url(user_id, activation_token)
    params = { user_id: user_id, activation_token: activation_token }
    default_options = Rails.application.config.action_mailer.default_url_options
    URI::Generic.build(default_options.merge(path: '/sofia_accounts/activate_account', query: params.to_query)).to_s
  end

  def self.new_activation_link_url(user_id)
    params = { user_id: user_id }
    default_options = Rails.application.config.action_mailer.default_url_options
    URI::Generic.build(default_options.merge(path: '/sofia_accounts/new_activation_link', query: params.to_query)).to_s
  end

  def self.forgot_password_url
    default_options = Rails.application.config.action_mailer.default_url_options
    URI::Generic.build(default_options.merge(path: '/sofia_accounts/forgot_password')).to_s
  end

  def reset_password_url(activation_token)
    params = { activation_token: activation_token }
    default_options = Rails.application.config.action_mailer.default_url_options
    URI::Generic.build(default_options.merge(path: "/sofia_accounts/#{id}/reset_password", query: params.to_query)).to_s
  end
end
