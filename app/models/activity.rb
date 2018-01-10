class Activity < ApplicationRecord
  has_many :orders, dependent: :destroy
  has_many :credit_mutations, dependent: :destroy
  belongs_to :price_list
  belongs_to :created_by, class_name: 'User'

  validates :title, :start_time, :end_time, :price_list, :created_by, presence: true

  validates_datetime :end_time, after: :start_time

  validate :activity_not_expired

  scope :upcoming, (lambda {
    where('(start_time < ? and end_time > ?) or start_time > ?', Time.zone.now,
          Time.zone.now, Time.zone.now).order(:start_time, :end_time)
  })

  delegate :products, to: :price_list

  def credit_mutations_total
    credit_mutations.map(&:amount).reduce(:+) || 0
  end

  def sold_products
    orders.map(&:order_rows).flatten.map(&:product)
  end

  def revenue
    orders.map(&:order_rows).flatten.map(&:row_total).reduce(:+) || 0
  end

  def bartenders
    orders.map(&:created_by).uniq
  end

  def expired?
    return false if end_time.blank?
    (end_time + 1.month) < Time.zone.now
  end

  def expiration_date
    end_time + 1.month
  end

  private

  def activity_not_expired
    errors.add(:base, 'Activity was changed after expiration date') if expired? && changed?
  end
end
