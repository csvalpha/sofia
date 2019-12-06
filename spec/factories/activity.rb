FactoryBot.define do
  factory :activity do
    title { Faker::Book.title }
    start_time { Faker::Time.between(1.day.ago, Time.zone.today).beginning_of_hour }
    end_time { Faker::Time.between(1.day.from_now, 2.days.from_now).beginning_of_hour }
    association :created_by, factory: :user
    price_list

    trait :locked do
      start_time { Faker::Time.between(80.days.ago, 75.days.ago).beginning_of_hour }
      end_time { 74.days.ago.beginning_of_hour }

      before(:create) do |activity, evaluator|
        # Set end_time back to valid value, otherwise validations will not pass
        activity.end_time = Faker::Time.between(1.day.from_now, 2.days.from_now).beginning_of_hour
      end

      after(:create) do |activity, evaluator|
        # Skip validations and make activity locked by setting end_time back
        activity.update_attribute(:end_time, 74.days.ago.beginning_of_hour)
      end
    end

    trait :manually_locked do
      association :locked_by, factory: :user
    end
  end
end
