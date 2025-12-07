class Payment < ApplicationRecord
  # See: https://github.com/rails/rails/issues/31234#issuecomment-446629054
  # Because of the open enum-state a payment needs to be able to be in (Mollie requirement),
  # we're undefining #open before defining it with the enum.
  class << self
    undef_method :open
  end
  # See: https://docs.mollie.com/payments/status-changes
  enum :status, { open: 0, pending: 1, paid: 2, failed: 3, canceled: 4, expired: 5 }
  COMPLETE_STATUSES = %w[paid failed canceled expired].freeze

  belongs_to :user, optional: true
  belongs_to :invoice, optional: true

  validates :status, presence: true
  validates :amount, presence: true

  validate :user_xor_invoice
  validate :user_amount

  scope :not_completed, -> { where.not(status: COMPLETE_STATUSES) }

  after_save :process_complete_payment!

  def completed?
    COMPLETE_STATUSES.include?(status)
  end

  def self.create_with_mollie(description, attributes = nil) # rubocop:disable Metrics/AbcSize
    is_mandate_setup = attributes&.delete(:first_payment)
    obj = create(attributes)
    return obj unless obj.valid?

    mollie_payment_attrs = {
      amount: { value: format('%<amount>.2f', amount: attributes[:amount]), currency: 'EUR' },
      description:
    }

    if is_mandate_setup
      # For mandate setup, include sequenceType and the redirect URL for mandate callback
      mollie_payment_attrs[:sequenceType] = 'first'
      mollie_payment_attrs[:redirectUrl] = "http://#{Rails.application.config.x.sofia_host}/payments/#{obj.id}/mandate_callback"
    else
      mollie_payment_attrs[:redirectUrl] = "http://#{Rails.application.config.x.sofia_host}/payments/#{obj.id}/callback"
    end

    mollie_payment = Mollie::Payment.create(mollie_payment_attrs)

    obj.update(mollie_id: mollie_payment.id)
    obj
  end

  def mollie_payment
    Mollie::Payment.get(mollie_id)
  end

  def process_complete_payment!
    return unless status_previously_was != 'paid' && status == 'paid'

    # Skip credit mutation for mandate setup payments (1 cent)
    return if amount == 0.01

    process_user! if user
    process_invoice! if invoice
  end

  def process_user!
    mutation = CreditMutation.create(user:,
                                     amount:,
                                     description: 'iDEAL inleg', created_by: user)

    UserCreditMailer.new_credit_mutation_mail(mutation).deliver_later
  end

  def process_invoice!
    CreditMutation.create(user: invoice.user,
                          amount:,
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
    # Allow 1 cent payments for mandate setup
    return if amount == 0.01

    errors.add(:amount, 'must be bigger than or equal to 20') unless amount && (amount >= 20)
  end
end
