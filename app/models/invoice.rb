class Invoice < ApplicationRecord
  enum status: { pending: 0, sent: 1 }

  belongs_to :user
  belongs_to :activity
  has_many :invoice_rows

  validates :user, :activity, presence: true
  validate :activity_is_locked

  before_save :set_amount
  before_save :set_human_id

  def name
    name_override || user.name
  end

  def email
    email_override || user.email
  end

  private

  def set_human_id
    this_year_invoices = Invoice.where("human_id LIKE '?%'", Time.zone.now.year)
    invoice_number = this_year_invoices.count + 1

    self.human_id = "#{Time.zone.now.year}#{invoice_number.to_s.rjust(4, '0')}"
  end

  def set_amount
    self.amount = activity.revenue_by_user(user)
  end

  def activity_is_locked
    errors.add(:activity, 'should be locked') unless activity&.locked?
  end
end
