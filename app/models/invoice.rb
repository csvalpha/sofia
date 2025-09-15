class Invoice < ApplicationRecord
  has_secure_token

  enum :status, { pending: 0, sent: 1, paid: 3 }

  belongs_to :user
  belongs_to :activity
  has_many :rows, class_name: 'InvoiceRow', dependent: :destroy
  accepts_nested_attributes_for :rows

  validate :activity_is_locked

  before_create :set_human_id

  def name
    name_override || user.name
  end

  def email
    email_override || user.email
  end

  def amount
    activity.revenue_by_user(user) + rows.sum(&:total)
  end

  def row_amount
    rows.sum(&:total)
  end

  private

  def set_human_id
    year_prefix = Time.zone.now.year.to_s
    this_year_invoices = Invoice.where("human_id LIKE ?", "#{year_prefix}%")
    invoice_number = this_year_invoices.count + 1

    self.human_id = "#{year_prefix}#{invoice_number.to_s.rjust(4, '0')}"
  end

  def activity_is_locked
    errors.add(:activity, 'should be locked') unless activity&.locked?
  end
end
