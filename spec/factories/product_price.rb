FactoryGirl.define do
  factory :product_price do
    amount { rand(0..5.00) }
    product
    price_list
  end
end
