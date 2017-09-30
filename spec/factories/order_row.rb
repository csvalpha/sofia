FactoryGirl.define do
  factory :order_row do
    order
    product

    product_count { rand(1...5) }
  end
end
