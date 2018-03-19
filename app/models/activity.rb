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
    credit_mutations.map(&:amount).reduce(:+) || 0
  end

  def revenue_hash
    @revenue_hash ||= orders.group_by(&:paid_with_cash).map { |h|
      [h[0] ? :cash : :not_cash, h[1].map(&:order_rows)
                                     .flatten
                                     .map(&:row_total).reduce(:+)]
    }.to_h
  end

  def revenue_by_category
    @totals_hash ||= orders.map(&:order_rows).flatten.group_by {
      |r| r.product.category
    }.map { |cat| cat[1] = cat[1].map(&:row_total).sum; cat }.to_h
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
