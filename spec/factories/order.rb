FactoryBot.define do
  factory :order do
    activity
    user
    association :created_by, factory: :user

    trait :cash do
      after(:build) do |order|
        order.user = nil
        order.paid_with_cash = true
      end
    end

    trait :pin do
      after(:build) do |order|
        order.user = nil
        order.paid_with_pin = true
      end
    end

    trait :with_items do
      transient do
        products { [] }
      end

      after(:create) do |order, evaluator|
        create :order_row, order:, product: evaluator.products.sample, product_count: 1
      end
    end

    factory :order_with_items, traits: [:with_items]
  end
end
