FactoryBot.define do
  factory :invoice do
    user
    created_at { Faker::Time.between(from: 1.day.ago, to: 2.days.ago) }

    association :activity, factory: %i[activity manually_locked]

    trait :with_rows do
      after(:create) do |invoice, _evaluator|
        create :invoice_row, invoice: invoice
      end
    end
  end
end
