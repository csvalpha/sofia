activities = []
[0,1,2,3].each do
  activities << FactoryGirl.create(:activity)
end

products = []
[0,1,2,3].each do
  products << FactoryGirl.create(:product)
end

products.each do |product|
  activities.each do |activity|
    # binding.pry
    FactoryGirl.create(:product_price, product: product, price_list: activity.price_list)
  end
end

activities.each do |activity|
  # TODO remove amount, this should be calculated in model
  [0,1,2].each do
    FactoryGirl.create(:transaction, product: products.sample, activity: activity, amount: 8)
  end
end
