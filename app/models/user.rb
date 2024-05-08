class User < ApplicationRecord # rubocop:disable Metrics/ClassLength
  devise :omniauthable, omniauth_providers: [:amber_oauth2, :identity]
  has_many :orders, dependent: :destroy
  has_many :order_rows, through: :orders, dependent: :destroy
  has_many :credit_mutations, dependent: :destroy
  has_many :activities, dependent: :destroy, foreign_key: 'created_by_id', inverse_of: :created_by

  has_many :roles_users, class_name: 'RolesUsers', dependent: :destroy, inverse_of: :user
  has_many :roles, through: :roles_users

  validates :name, presence: true
  validates :uid, uniqueness: true, allow_blank: true
  validate :no_deactivation_when_nonzero_credit
  validates :email, format: { with: Devise.email_regexp }, allow_blank: true
  validates :email, presence: true, if: ->(user) { !user.deactivated && user.identity.present? }

  scope :in_amber, (-> { where(provider: 'amber_oauth2') })
  scope :identity, (-> { where(provider: 'identity') })
  scope :manual, (-> { where(provider: nil) })
  scope :active, (-> {
    where(deactivated: false).where('(provider IS NULL OR provider != ?) OR (provider = ? AND id IN (?))', 'identity', 'identity', Identity.select('user_id'))
  })
  scope :not_activated, (-> { where(deactivated: false, provider: 'identity').where('id NOT IN (?)', Identity.select('user_id')) })
  scope :deactivated, (-> { where(deactivated: true) })
  scope :treasurer, (-> { joins(:roles).merge(Role.treasurer) })

  has_one :identity, dependent: :delete
  accepts_nested_attributes_for :identity

  attr_accessor :current_activity

  before_save do
    if new_record? && self.provider == 'identity'
      self.activation_token = SecureRandom.urlsafe_base64
      self.activation_token_valid_till = 5.day.from_now
    end
  end

  after_save do
    a = age
    if self.deactivated && (new_record? || self.deactivated_previously_changed?(from: false, to: true))
      archive!
    end
  end

  after_create do
    if User.identity.exists?(id: self.id)
      UserMailer.account_creation_email(self).deliver_later
    end
  end

  def credit
    credit_mutations.sum('amount') - order_rows.sum('product_count * price_per_product')
  end

  def avatar_thumb_or_default_url
    return '/images/avatar_thumb_default.png' unless avatar_thumb_url

    "#{Rails.application.config.x.amber_api_url}#{avatar_thumb_url}"
  end

  def age
    return nil unless birthday

    age = Time.zone.now.year - birthday.year
    age -= 1 if Time.zone.now < birthday + age.years
    age
  end

  def minor
    return false unless age

    age < 18
  end

  def insufficient_credit
    provider == 'amber_oauth2' and credit.negative?
  end

  def can_order(activity = nil)
    activity ||= current_activity
    if activity.nil?
      !insufficient_credit
    else
      !insufficient_credit or activity.orders.select { |order| order.user_id == id }.any?
    end
  end

  def treasurer?
    @treasurer ||= roles.where(role_type: :treasurer).any?
  end

  def main_bartender?
    @main_bartender ||= roles.where(role_type: :main_bartender).any?
  end

  def update_role(groups)
    if (User.in_amber.exists?(self.id))
      roles_to_have = Role.where(group_uid: groups)
      roles_users_to_have = roles_to_have.map { |role| RolesUsers.find_or_create_by(role: role, user: self) }

      roles_users_not_to_have = roles_users - roles_users_to_have
      roles_users_not_to_have.map(&:destroy)
    end
  end

  def archive!
    attributes.each_key do |attribute|
      self[attribute] = nil unless %w[deleted_at updated_at created_at provider identity id uid].include? attribute
    end
    self.name = "Gearchiveerde gebruiker #{id}"
    self.deactivated = true
    save & versions.destroy_all
  end

  # TODO: Spec this method
  # :nocov:
  def self.from_omniauth(auth) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    user = where(provider: auth.provider, uid: auth.uid).first_or_create do |u|
      u.name = auth[:info][:name]
    end
    user.update_role(auth[:info][:groups])
    user.update(
      name: auth[:info][:name],
      email: auth[:info][:email],
      avatar_thumb_url: auth[:info][:avatar_thumb_url],
      birthday: auth[:info][:birthday]
    )
    user
  end

  def self.from_omniauth_inspect(auth)
    identity = Identity.find(auth.uid)
    identity.user
  end

  # :nocov:

  def self.full_name_from_attributes(first_name, last_name_prefix, last_name, nickname)
    full_name = first_name
    full_name += " (#{nickname})" if nickname.present?
    full_name += " #{last_name_prefix}" if last_name_prefix.present?
    full_name += " #{last_name}" if last_name.present?
    full_name
  end

  def self.calculate_credits
    credits = User.all.left_outer_joins(:credit_mutations).group(:id).sum('amount')
    costs = User.calculate_spendings

    credits.each_with_object({}) { |(id, credit), h| h[id] = credit - costs.fetch(id, 0) }
  end

  def self.calculate_spendings(from: '01-01-1970', to: Time.zone.now)
    User.all.joins(:order_rows)
        .where('orders.created_at >= ? AND orders.created_at < ?', from, to)
        .group(:id).sum('product_count * price_per_product')
  end

  def self.orderscreen_json_includes
    %i[credit avatar_thumb_or_default_url minor insufficient_credit can_order]
  end

  private

  def no_deactivation_when_nonzero_credit
    return unless deactivated && credit != 0

    errors.add(:deactivated, 'cannot deactivate when credit is non zero')
  end
end
