class Payment < ApplicationRecord
  # See: https://github.com/rails/rails/issues/31234#issuecomment-446629054
  # Because of the open enum-state a payment needs to be able to be in (Mollie requirement),
  # we're undefining #open before defining it with the enum.
  class << self
    undef_method :open
  end
  # See: https://docs.mollie.com/payments/status-changes
  enum status: { open: 0, pending: 1, paid: 2, failed: 3, canceled: 4, expired: 5 }
  COMPLETE_STATUSES = %w[paid failed canceled expired].freeze

  belongs_to :user, optional: true
  belongs_to :invoice, optional: true

  validates :status, presence: true
  validates :amount, presence: true

  validate :user_xor_invoice
  validate :user_amount

  scope :not_completed, (-> { where.not(status: COMPLETE_STATUSES) })

  after_save :process_complete_payment!

  def completed?
    COMPLETE_STATUSES.include?(status)
  end

  def self.create_with_mollie(description, attributes = nil)
    obj = create(attributes)
    return obj unless obj.valid?

    mollie_payment = Mollie::Payment.create(
      amount: { value: format('%<amount>.2f', amount: attributes[:amount]), currency: 'EUR' },
      description: description,
      redirect_url: "http://#{Rails.application.config.x.tomato_host}/payments/#{obj.id}/callback"
    )

    obj.update(mollie_id: mollie_payment.id)
    obj
  end

  def mollie_payment
    Mollie::Payment.get(mollie_id)
  end

  def process_complete_payment!
    return unless status_previously_was != 'paid' and status == 'paid'

    process_user! if user
    process_invoice! if invoice
  end

  def process_user!
    mutation = CreditMutation.create(user: user,
                                     amount: amount,
                                     description: 'iDEAL inleg', created_by: user)

    UserCreditMailer.new_credit_mutation_mail(mutation).deliver_later
  end

  def process_invoice!
    CreditMutation.create(user: invoice.user,
                          amount: amount,
                          description: "Betaling factuur #{invoice.human_id}", created_by: invoice.user)
    invoice.update(status: 'paid')

    InvoiceMailer.invoice_paid(invoice).deliver_later
  end

  private

  def user_xor_invoice
    errors.add(:payment, 'must belong to a user xor invoice') unless user.present? ^ invoice.present?
  end

  def user_amount
    return unless user

    errors.add(:amount, 'must be bigger than or equal to 20') unless amount && (amount >= 20)
  end
end
