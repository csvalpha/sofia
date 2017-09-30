FactoryGirl.define do
  factory :activity do
    title { Faker::Book.title }
    start_time { Faker::Time.between(1.day.ago, Time.zone.today).beginning_of_minute }
    end_time { Faker::Time.between(1.day.from_now, 2.days.from_now).beginning_of_minute }
    price_list
  end
end
