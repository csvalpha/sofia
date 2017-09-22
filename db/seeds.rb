activities = []
4.times do
  activities << FactoryGirl.create(:activity)
end

products = []
4.times do
  products << FactoryGirl.create(:product)
end

users = []
5.times do
  users << FactoryGirl.create(:user)
end

products.each do |product|
  activities.each do |activity|
    # binding.pry
    FactoryGirl.create(:product_price, product: product, price_list: activity.price_list)
  end
end

activities.each do |activity|
  3.times do
    product = products.sample
    FactoryGirl.create(:transaction, product: product, activity: activity,
                                     amount: activity.price_list.product_price_for(product).amount,
                                     user: users.sample)
  end
end
