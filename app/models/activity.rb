class Activity < ApplicationRecord
  has_many :orders, dependent: :destroy
  has_many :credit_mutations, dependent: :destroy
  belongs_to :price_list
  belongs_to :created_by, class_name: 'User'

  validates :title,       presence: true
  validates :start_time,  presence: true
  validates :end_time,    presence: true
  validates :price_list,  presence: true
  validates :created_by, presence: true
  validates_datetime :end_time, after: :start_time

  scope :upcoming, (lambda {
    where('(start_time < ? and end_time > ?) or start_time > ?', Time.zone.now,
          Time.zone.now, Time.zone.now).order(:start_time, :end_time)
  })

  scope :current, (lambda {
    where('(start_time < ? and end_time > ?)', Time.zone.now,
          Time.zone.now).order(:start_time, :end_time)
  })

  delegate :products, to: :price_list

  def humanized_start_time
    start_time.strftime('%d %B %Y %H:%M')
  end

  def humanized_end_time
    end_time.strftime('%d %B %Y %H:%M')
  end

  def credit_mutations_total
    credit_mutations.map(&:amount).reduce(:+)
  end

  def sold_products
    orders.map(&:order_rows).flatten.map(&:product)
  end

  def revenue
    orders.map(&:order_rows).flatten.map(&:row_total).reduce(:+)
  end

  def bartenders
    orders.map(&:created_by).uniq
  end

  def products_total_for_user(user)
    totals = {}
    sold_products.each do |product|
      total = product_total_for_user(user, product)
      totals[product.name] = total if total
    end
    totals
  end

  def product_total_for_user(user, product)
    orders.where(user: user).map {
        |order| order.order_rows.where(product: product)
    }.flatten.map(&:product_count).reduce(&:+)

  end
end
