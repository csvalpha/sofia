class Activity < ApplicationRecord
  has_many :orders, dependent: :destroy
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

  def bartenders
    orders.map(&:created_by).uniq
  end
end
