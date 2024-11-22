class Role < ApplicationRecord
  enum role_type: { treasurer: 0, main_bartender: 1 }

  validates :role_type, :group_uid, presence: true
  has_many :roles_users, class_name: 'RolesUsers', dependent: :destroy, inverse_of: :role
  has_many :users, through: :roles_users

  def name
    if treasurer?
      Rails.application.config.x.treasurer_title.capitalize
    elsif main_bartender?
      'Hoofdtapper'
    end
  end
end
