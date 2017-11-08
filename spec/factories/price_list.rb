FactoryGirl.define do
  factory :price_list do
    name { Faker::Book.title }

    transient do
      products { create_list(:product, 2) } unless Product.any?
    end

    after(:create) do |price_list, evaluator|
      evaluator.products.each do |product|
        create(:product_price, price_list: price_list, product: product)
      end
    end
  end
end
