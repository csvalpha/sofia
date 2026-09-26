class RolesUsers < ApplicationRecord
  belongs_to :user
  belongs_to :role

  validates :user_id, uniqueness: { scope: %i[role_id created_at] }

  delegate :name, to: :role
end
