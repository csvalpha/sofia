FactoryBot.define do
  factory :invoice do
    user
    association :activity, factory: %i[activity manually_locked]

    trait :with_rows do
      after(:create) do |invoice, _evaluator|
        create :invoice_row, invoice: invoice
      end
    end
  end
end
