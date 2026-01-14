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

  def self.create_with_mollie(description, attributes = nil)
    is_mandate_setup = attributes&.delete(:first_payment)
    obj = create(attributes)
    return obj unless obj.valid?

    mollie_payment = create_mollie_payment(description, attributes, obj, is_mandate_setup)
    obj.update(mollie_id: mollie_payment.id)
    obj
  end

  def self.create_mollie_payment(description, attributes, obj, is_mandate_setup)
    mollie_payment_attrs = build_mollie_attrs(description, attributes, obj, is_mandate_setup)
    Mollie::Payment.create(mollie_payment_attrs)
  end

  def self.build_mollie_attrs(description, attributes, obj, is_mandate_setup)
    attrs = build_base_mollie_attrs(description, attributes)
    add_redirect_url(attrs, obj, is_mandate_setup)
    attrs
  end

  def self.build_base_mollie_attrs(description, attributes)
    {
      amount: { value: format('%.2f', attributes[:amount]), currency: 'EUR' },
      description:
    }
  end

  def self.add_redirect_url(attrs, obj, is_mandate_setup)
    if is_mandate_setup
      attrs[:sequenceType] = 'first'
      attrs[:redirectUrl] = "http://#{Rails.application.config.x.sofia_host}/payments/#{obj.id}/mandate_callback"
    else
      attrs[:redirectUrl] = "http://#{Rails.application.config.x.sofia_host}/payments/#{obj.id}/callback"
    end
  end

  private_class_method :create_mollie_payment, :build_mollie_attrs, :build_base_mollie_attrs, :add_redirect_url

  def mollie_payment
    Mollie::Payment.get(mollie_id)
  end

  def process_complete_payment!
    return unless status_previously_was != 'paid' && status == 'paid'

    # Skip credit mutation for mandate setup payments (1 cent)
    return if setup_payment?

    process_user! if user
    process_invoice! if invoice
  end

  def setup_payment?
    amount.to_d == 0.01.to_d
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
    return if setup_payment?

    min_amount = Rails.application.config.x.min_payment_amount
    errors.add(:amount, "must be bigger than or equal to €#{format('%.2f', min_amount)}") unless amount && (amount >= min_amount)
  end
end
