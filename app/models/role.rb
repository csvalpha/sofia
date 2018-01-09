class Role < ApplicationRecord
  enum role_type: { treasurer: 0, main_bartender: 1 }

  validates :role_type, :group_uid, presence: true
  has_many :roles_users, class_name: 'RolesUsers', dependent: :destroy, inverse_of: :role

  def name
    if treasurer?
      'Penningmeester'
    elsif main_bartender?
      'Hoofdtapper'
    end
  end
end
