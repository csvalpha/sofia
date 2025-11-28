class Role < ApplicationRecord
  enum :role_type, { treasurer: 0, main_bartender: 1, renting_manager: 2 }

  validates :role_type, presence: true
  has_many :roles_users, class_name: 'RolesUsers', dependent: :destroy
  has_many :users, through: :roles_users

  def name
    if treasurer?
      Rails.application.config.x.treasurer_title.capitalize
    elsif main_bartender?
      'Hoofdtapper'
    elsif renting_manager?
      'Verhuur manager'
    end
  end
end
