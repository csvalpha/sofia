FactoryGirl.define do
  factory :order_row do
    order
    product_count { rand(1...5) }

    after :build do |row|
      row.product ||= row.order ? row.order.activity.price_list.products.sample : build(:product)
    end
  end
end
