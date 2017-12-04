class RolesUsers < ApplicationRecord
  belongs_to :user
  belongs_to :role

  validates :user, :role, presence: true

  delegate :name, to: :role
end
