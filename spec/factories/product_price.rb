FactoryBot.define do
  factory :product_price do
    # Never 0: order rows copy this price and require price_per_product > 0
    price { rand(0.01..5.00).round(2) }
    product
    price_list
  end
end
