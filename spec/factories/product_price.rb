FactoryGirl.define do
  factory :product_price do
    amount { rand(0..250.0) }
    product
    price_list
  end
end
