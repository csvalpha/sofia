activities = []
4.times do
  activities << FactoryGirl.create(:activity)
end

products = []
products << Product.create(name: 'Bier (glas)', contains_alcohol: true)
products << Product.create(name: 'Bier (pul)', contains_alcohol: true)
products << Product.create(name: 'Bier (pitcher)', contains_alcohol: true)
products << Product.create(name: 'Speciaalbier', contains_alcohol: true)
products << Product.create(name: 'Sterke drank', contains_alcohol: true)
products << Product.create(name: 'Dure Whisky', contains_alcohol: true)
products << Product.create(name: 'Weduwe Joustra Beerenburg', contains_alcohol: true)
products << Product.create(name: 'Wijn (glas)', contains_alcohol: true)
products << Product.create(name: 'Wijn (fles)', contains_alcohol: true)
products << Product.create(name: 'Fris')
products << Product.create(name: 'Fris (klein)')
products << Product.create(name: 'Red Bull')
products << Product.create(name: 'Tosti')
products << Product.create(name: 'Nootjes')
products << Product.create(name: 'Chips')
products << Product.create(name: 'Sigaar')
products << Product.create(name: 'Sigaar (duur)')
products << Product.create(name: '12+1', contains_alcohol: true)

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
