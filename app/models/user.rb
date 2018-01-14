class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:banana_oauth2]
  has_many :orders, dependent: :destroy
  has_many :order_rows, through: :orders, dependent: :destroy
  has_many :credit_mutations, dependent: :destroy
  has_many :activities, dependent: :destroy

  has_many :roles_users, class_name: 'RolesUsers', dependent: :destroy, inverse_of: :user

  validates :name, presence: true
  validates :uid, uniqueness: true, allow_blank: true

  scope :in_banana, (-> { where(provider: 'banana_oauth2') })

  def credit
    credit_mutations.map(&:amount).sum - order_rows.map(&:row_total).sum
  end

  def roles
    @roles ||= roles_users.includes(:role).map(&:role).flatten.uniq
  end

  def avatar_thumb_or_default_url
    return '/images/avatar_thumb_default.png' unless avatar_thumb_url
    "#{Rails.application.config.x.banana_api_host}#{avatar_thumb_url}"
  end

  def treasurer?
    @treasurer ||= roles.map(&:treasurer?).any?
  end

  def main_bartender?
    @main_bartender ||= roles.map(&:main_bartender?).any?
  end

  def update_role(memberships)
    roles_to_have = Role.where(group_uid: memberships)
    roles_users_to_have = roles_to_have.map { |role| RolesUsers.find_or_create_by(role: role, user: self) }

    roles_users_not_to_have = roles_users - roles_users_to_have
    roles_users_not_to_have.map(&:destroy)
  end

  # TODO: Spec this method
  # :nocov:
  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_create do |u|
      u.name = auth[:info][:name]
    end
    user.update_role(auth[:info][:memberships])
    user
  end

  def self.full_name_from_attributes(first_name, last_name_prefix, last_name)
    [first_name, last_name_prefix, last_name].reject(&:blank?).join(' ')
  end
end
