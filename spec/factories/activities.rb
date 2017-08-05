FactoryGirl.define do
  factory :activity do
    title { Faker::Book.title }
    start_time { Faker::Time.between(1.day.ago, Time.zone.today) }
    end_time { Faker::Time.between(1.day.from_now, 2.day.from_now) }
    price_list
  end
end
