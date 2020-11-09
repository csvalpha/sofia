FactoryBot.define do
  factory :invoice do
    user
    created_at { Faker::Time.between(from: 1.day.ago, to: 2.days.ago) }

    association :activity, factory: %i[activity manually_locked]
  end
end
