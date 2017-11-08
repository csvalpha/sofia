FactoryGirl.define do
  factory :price_list do
    name { Faker::Book.title }

    trait :with_items do
      after(:create) do |price_list|
        Product.all.each do |product|
          create(:product_price, price_list: price_list, product: product)
        end
      end
    end
  end
end
