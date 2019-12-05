class Activity < ApplicationRecord
  has_many :orders, dependent: :destroy
  has_many :credit_mutations, dependent: :destroy
  belongs_to :price_list
  belongs_to :created_by, class_name: 'User', inverse_of: :activities

  validates :title, :start_time, :end_time, :price_list, :created_by, presence: true
  validates_datetime :end_time, after: :start_time
  validate :activity_not_locked

  before_destroy :destroyable?

  scope :upcoming, (lambda {
    where('(start_time < ? and end_time > ?) or start_time > ?', Time.zone.now,
          Time.zone.now, Time.zone.now).order(:start_time, :end_time)
  })

  scope :current, (lambda {
    where('(start_time < ? and end_time > ?)', Time.zone.now,
          Time.zone.now).order(:start_time, :end_time)
  })

  delegate :products, to: :price_list

  def credit_mutations_total
    @credit_mutations_total ||= credit_mutations.sum(:amount)
  end

  def revenue_with_cash
    @revenue_with_cash ||= begin
      OrderRow.where(order: orders.where(paid_with_cash: true)).sum('product_count * price_per_product')
    end
  end

  def revenue_with_pin
    @revenue_with_pin ||= begin
      OrderRow.where(order: orders.where(paid_with_pin: true)).sum('product_count * price_per_product')
    end
  end

  def revenue_with_credit
    @revenue_with_credit ||= begin
      OrderRow.where(order: orders.where(paid_with_cash: false, paid_with_pin: false)).sum('product_count * price_per_product')
    end
  end

  def cash_total
    @cash_total ||= revenue_with_cash + credit_mutations_total
  end

  def revenue_total
    @revenue_total ||= revenue_with_cash + revenue_with_pin + revenue_with_credit
  end

  def count_per_product(**args)
    records = orders.where(**args)

    @count_per_product = OrderRow.where(order: records).group(:product_id, :name).joins(:product)
                                 .pluck(:name, 'SUM(product_count)', 'SUM(product_count * price_per_product)')
    @count_per_product.map { |name, amount, price| { name: name, amount: amount.to_i, price: price.to_f } }
  end

  def revenue_by_category
    @revenue_by_category ||= begin
      revenue_per_product.each_with_object(Hash.new(0)) do |(product, price), hash|
        hash[product[:category]] += price
        hash
      end
    end
  end

  def revenue_per_product
    @revenue_per_product ||= begin
      OrderRow.where(order: orders).group(:product).sum('product_count * price_per_product')
    end
  end

  def bartenders
    orders.map(&:created_by).uniq || []
  end

  def locked?
    end_time && Time.zone.now > lock_date
  end

  def lock_date
    end_time + 2.months
  end

  private

  def activity_not_locked
    errors.add(:base, 'Activity cannot be changed after lock date') if locked? && changed?
  end

  def destroyable?
    throw(:abort) if locked?
  end
end
