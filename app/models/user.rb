class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:banana_oauth2]
  has_many :orders, dependent: :destroy
  has_many :credit_mutations, dependent: :destroy

  has_many :roles_users, class_name: 'RolesUsers', dependent: :destroy

  validates :name, presence: true
  validates :uid, uniqueness: true, allow_blank: true

  scope :in_banana, (-> { where(provider: 'banana_oauth2') })

  def credit
    credit_mutations.map(&:amount).sum - orders.map(&:order_total).sum
  end

  def roles
    @roles ||= roles_users.includes(:role).map(&:role).flatten.uniq
  end

  def treasurer?
    roles.map(&:name).include?('Treasurer')
  end

  def main_bartender?
    roles.map(&:name).include?('Main Bartender')
  end

  def update_role(memberships)
    RolesUsers.where(user_id: id).map(&:destroy)
    return unless memberships&.any?
    my_roles = []
    memberships.each do |membership_id|
      roles = Role.where(group_uid: membership_id)
      roles.each do |role|
        my_roles << RolesUsers.with_deleted.find_or_create_by(role: role, user: self) if role
      end
      my_roles.map(&:restore)
    end
  end

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
