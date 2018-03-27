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

  def revenue_without_cash
    @revenue_without_cash ||= begin
      OrderRow.where(order: orders.where(paid_with_cash: false)).sum('product_count * price_per_product')
    end
  end

  def count_per_product
    @count_per_product ||= OrderRow.where(order: orders).group(:product).sum(:product_count)
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
