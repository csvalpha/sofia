FactoryBot.define do
  factory :activity do
    title { Faker::Book.title }
    start_time { Faker::Time.between(1.day.ago, Time.zone.today).beginning_of_minute }
    end_time { Faker::Time.between(1.day.from_now, 2.days.from_now).beginning_of_minute }
    association :created_by, factory: :user
    price_list

    trait :locked do
      start_time { Faker::Time.between(3.months.ago, 2.months.ago).beginning_of_minute }
      end_time { Faker::Time.between(2.months.ago, 1.month.ago).beginning_of_minute }
    end
  end
end
