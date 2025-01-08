FactoryBot.define do
  factory :price_list do
    name { Faker::Book.title }

    transient do
      with_all_products { false }
      with_specific_products { false }
      products { [] }
    end

    trait :with_all_products do
      with_all_products { true }
    end

    trait :with_products do
      with_specific_products { true }
    end

    trait :archived do
      archived_at { 1.day.ago }
    end

    after(:create) do |price_list, evaluator|
      if evaluator.with_all_products
        Product.all.each do |product|
          create(:product_price, price_list:, product:)
        end
      elsif evaluator.with_specific_products
        evaluator.products.each do |product|
          create(:product_price, price_list:, product:)
        end
      else
        create_list(:product_price, 2, price_list:)
      end
    end
  end
end
