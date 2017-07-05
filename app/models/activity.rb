class Activity < ApplicationRecord
  validates :title,       presence: true
  validates :start_time,  presence: true
  validates :end_time,    presence: true
  validates_datetime :end_time, after: :start_time

  scope :upcoming, (lambda {
    where('(start_time < ? and end_time > ?) or start_time > ?', Time.zone.now,
          Time.zone.now, Time.zone.now).order(:start_time, :end_time)
  })
end
