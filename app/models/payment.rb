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

  belongs_to :user

  validates :user, :status, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 20 }, presence: true

  scope :not_completed, (-> { where.not(status: COMPLETE_STATUSES) })

  def completed
    COMPLETE_STATUSES.include?(status)
  end

  def self.create_with_mollie(attributes = nil)
    obj = create(attributes)
    return obj unless obj.valid?

    mollie_payment = Mollie::Payment.create(
      amount: { value: format('%<amount>.2f', amount: attributes[:amount]), currency: 'EUR' },
      description: 'Sofia zatladder saldo inleg',
      redirect_url: "http://#{Rails.application.config.x.tomato_host}/payments/#{obj.id}/callback"
    )

    obj.update(mollie_id: mollie_payment.id)
    obj
  end

  def mollie_payment
    Mollie::Payment.get(mollie_id)
  end
end