class RolesUsers < ApplicationRecord
  belongs_to :user
  belongs_to :role

  delegate :name, to: :role
end
