class SofiaAccount < OmniAuth::Identity::Models::ActiveRecord
  has_one_time_password

  belongs_to :user

  validates :user, uniqueness: true # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :username, presence: true, uniqueness: true
  # the presence of :password is already checked by omniauth-sofia-account itself
  validates :password, length: { minimum: 12 }, allow_nil: true

  auth_key :username # specifies the field within the model that will be used during the login process as username

  def self.activate_account_url(user_id, activation_token)
    params = { user_id:, activation_token: }
    default_options = Rails.application.config.action_mailer.default_url_options
    URI::Generic.build(default_options.merge(path: '/sofia_accounts/activate_account', query: params.to_query)).to_s
  end

  def self.new_activation_link_url(user_id)
    params = { user_id: }
    default_options = Rails.application.config.action_mailer.default_url_options
    URI::Generic.build(default_options.merge(path: '/sofia_accounts/new_activation_link', query: params.to_query)).to_s
  end

  def self.forgot_password_url
    default_options = Rails.application.config.action_mailer.default_url_options
    URI::Generic.build(default_options.merge(path: '/sofia_accounts/forgot_password')).to_s
  end

  def reset_password_url(activation_token)
    params = { activation_token: }
    default_options = Rails.application.config.action_mailer.default_url_options
    URI::Generic.build(default_options.merge(path: "/sofia_accounts/#{id}/reset_password", query: params.to_query)).to_s
  end

  def self.find_for_login(identifier)
    return nil if identifier.blank?

    trimmed = identifier.to_s.strip
    find_by(username: trimmed) || User.where('LOWER(email) = LOWER(?)', trimmed).first&.sofia_account
  end

  def self.resolve_login_identifier(identifier)
    find_for_login(identifier)&.username
  end
end
