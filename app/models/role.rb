class Role < ApplicationRecord
  validates :name, inclusion: { in: ['Treasurer', 'Main Bartender'] }
  validates :group_uid, presence: true

  has_many :role_users, dependent: :destroy
end
