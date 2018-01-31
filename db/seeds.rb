require_relative './seeds/products.rb'

# rubocop:disable Rails/Output
p 'Seeding products...'
seed_products

p 'Seeding price lists...'
price_lists_names = %w[BSA Inkoopprijs Extern]
price_lists = []
price_lists_names.each do |name|
  price_lists << FactoryBot.create(:price_list, :with_all_products, name: name)
end

p 'Seeding users...'
users = []
5.times do
  users << FactoryBot.create(:user)
end

p 'Seeding activities...'
activities = []
4.times do
  activities << FactoryBot.create(:activity, price_list: price_lists.sample, created_by: users.sample)
end

p 'Seeding orders...'
activities.each do |activity|
  5.times do
    FactoryBot.create(:order, :with_items, products: activity.products.sample(2), activity: activity,
                                           user: users.sample, created_by: users.sample)
  end
end

p 'Seeding credit mutations...'
users.each do |user|
  FactoryBot.create_list(:credit_mutation, 3, user: user, created_by: users.sample)
end

p 'Seeding roles...'
Role.create(role_type: :treasurer, group_uid: 3)
Role.create(role_type: :main_bartender, group_uid: 3)
Role.create(role_type: :main_bartender, group_uid: 2)
# rubocop:enable Rails/Output
