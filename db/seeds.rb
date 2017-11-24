products = []
product_names_with_alcohol = ['Bier (glas)', 'Bier (pul)', 'Bier (pitcher)', 'Speciaalbier', 'Sterke drank',
                              'Dure Whisky', 'Weduwe Joustra Beerenburg', 'Wijn (glas)', 'Wijn (fles)', '12+1',
                              'Sigaar', 'Sigaar (duur)']

product_names_without_alcohol = ['Fris', 'Fris (klein)', 'Red Bull', 'Tosti', 'Nootjes', 'Chips']

product_names_with_alcohol.each do |name|
  products << Product.create(name: name, requires_age: true)
end

product_names_without_alcohol.each do |name|
  products << Product.create(name: name, requires_age: false)
end

activities = []
4.times do
  activities << FactoryGirl.create(:activity)
end

users = []
5.times do
  users << FactoryGirl.create(:user)
end

activities.each do |activity|
  products.each do |product|
    FactoryGirl.create(:product_price, product: product, price_list: activity.price_list)
  end
end

activities.each do |activity|
  5.times do
    FactoryGirl.create(:order, :with_items, products: activity.products.sample(5), activity: activity, user: users.sample)
  end
end

users.each do |user|
  FactoryGirl.create_list(:credit_mutation, 3, user: user)
end
