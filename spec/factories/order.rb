FactoryGirl.define do
  factory :order do
    activity
    user

    trait :with_items do
      transient do
        products []
      end

      after(:create) do |order, evaluator|
        create :order_row, order: order, product: evaluator.products.sample
      end
    end

    factory :order_with_items, traits: [:with_items]
  end
end
