class Identity < OmniAuth::Identity::Models::ActiveRecord
  has_one_time_password

  belongs_to :user

  validates :user, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  validates :password, length: { minimum: 12 }, allow_nil: true # the presence of :password is already checked by omniauth-identity itself

  auth_key :username    # optional: specifies the field within the model that will be used during the login process
                        # defaults to email, but may be username, uid, login, etc.

  def self.activate_account_url(user_id, activation_token)
    params = { user_id: user_id, activation_token: activation_token }
    default_options = Rails.application.config.action_mailer.default_url_options
    URI::Generic.build(default_options.merge(path: '/identities/activate_account', query: params.to_query)).to_s
  end

  def self.new_activation_link_url(user_id)
    params = { user_id: user_id }
    default_options = Rails.application.config.action_mailer.default_url_options
    URI::Generic.build(default_options.merge(path: '/identities/new_activation_link', query: params.to_query)).to_s
  end

  def self.forgot_password_url
    default_options = Rails.application.config.action_mailer.default_url_options
    URI::Generic.build(default_options.merge(path: '/identities/forgot_password')).to_s
  end

  def reset_password_url(activation_token)
    params = { activation_token: activation_token }
    default_options = Rails.application.config.action_mailer.default_url_options
    URI::Generic.build(default_options.merge(path: "/identities/#{id}/reset_password", query: params.to_query)).to_s
  end
  
end
