class Role < ApplicationRecord
  validates :name, inclusion: { in: ['Treasurer', 'Main Bartender'] }
  validates :group_uid, presence: true
end
