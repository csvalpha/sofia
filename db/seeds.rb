activities = []
4.times do
  activities << FactoryGirl.create(:activity)
end

products = []
product_names = ['Bier (glas)', 'Bier (pul)', 'Bier (pitcher)', 'Speciaalbier', 'Sterke drank', 'Dure Whisky',
                 'Weduwe Joustra Beerenburg', 'Wijn (glas)', 'Wijn (fles)', 'Fris', 'Fris (klein)', 'Red Bull', 'Tosti',
                 'Nootjes', 'Chips', 'Sigaar', 'Sigaar (duur)', '12+1']
product_names.each_with_index do |name, index|
  products << FactoryGirl.create(:product, name: name, position: index + 1)
end

users = []
5.times do
  users << FactoryGirl.create(:user)
end

products.each do |product|
  activities.each do |activity|
    FactoryGirl.create(:product_price, product: product, price_list: activity.price_list)
  end
end

activities.each do |activity|
  rand(3..10).times do
    FactoryGirl.create(:order, :with_items, products: products, activity: activity, user: users.sample)
  end
end

users.each do |user|
  FactoryGirl.create_list(:credit_mutation, 3, user: user)
end
