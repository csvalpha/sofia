class Role < ApplicationRecord
  validates :name, inclusion: { in: ['Treasurer', 'Main Bartender'] }
  validates :group_uid, presence: true

  has_many :roles_users, class_name: 'RolesUsers', dependent: :destroy
end
