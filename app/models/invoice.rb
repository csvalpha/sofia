class Invoice < ApplicationRecord
  belongs_to :user
  belongs_to :activity

  validates :user, :activity, :amount, presence: true

  before_save :set_amount

  private
  def set_amount
    self.amount = activity.revenue_by_user(user)
  end
end
