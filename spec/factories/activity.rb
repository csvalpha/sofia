FactoryBot.define do
  factory :activity do
    title { Faker::Book.title }
    start_time { Faker::Time.between(from: 1.day.ago, to: Time.zone.today).beginning_of_hour }
    end_time { Faker::Time.between(from: 1.day.from_now, to: 2.days.from_now).beginning_of_hour }
    created_by factory: %i[user]
    price_list

    trait :locked do
      start_time { Faker::Time.between(from: 80.days.ago, to: 75.days.ago).beginning_of_hour }
      end_time { 74.days.ago.beginning_of_hour }

      before(:create) do |activity, _evaluator|
        # Set end_time back to valid value, otherwise validations will not pass
        activity.end_time = Faker::Time.between(from: 1.day.from_now, to: 2.days.from_now).beginning_of_hour
      end

      after(:create) do |activity, _evaluator|
        # Skip validations and make activity locked by setting end_time back
        activity.update_attribute(:end_time, 74.days.ago.beginning_of_hour) # rubocop:disable Rails/SkipsModelValidations
      end
    end

    trait :manually_locked do
      locked_by factory: %i[user]
    end
  end
end
