class CreditMutation < ApplicationRecord
  belongs_to :user
  belongs_to :activity, optional: true
  belongs_to :created_by, class_name: 'User'

  validates :description, :user, :created_by, :amount, presence: true

  validate :activity_not_expired

  def activity_not_expired
    errors.add(:base, 'Activity has expired') if activity.present? &&
                                                 (persisted? || new_record?) &&
                                                 changed? &&
                                                 activity.expired?
  end
end
