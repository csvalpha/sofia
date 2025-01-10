require_relative 'seeds/products'

# rubocop:disable Rails/Output
p 'Seeding products...'
seed_products

p 'Seeding price lists...'
price_lists_names = %w[BSA Inkoopprijs Extern]
price_lists = price_lists_names.map do |name|
  FactoryBot.create(:price_list, :with_all_products, name:)
end

p 'Seeding users...'
users = []
4.times do
  users << FactoryBot.create(:user)
end
users << FactoryBot.create(:user, name: 'Benjamin Knopje', birthday: 16.years.ago)

p 'Seeding activities...'
activities = []
4.times do
  activities << FactoryBot.create(:activity, price_list: price_lists.sample, created_by: users.sample)
end

p 'Seeding orders...'
activities.each do |activity|
  5.times do
    FactoryBot.create(:order, :with_items, products: activity.products.sample(2), activity:,
                                           user: users.sample, created_by: users.sample)
  end
end

p 'Seeding credit mutations...'
users.each do |user|
  FactoryBot.create_list(:credit_mutation, 3, user:, created_by: users.sample,
                                              activity: (activities + [nil]).sample)
end

p 'Seeding invoices'
FactoryBot.create_list(:invoice, 3, :with_rows)

p 'Seeding roles...'
Role.create(role_type: :treasurer, group_uid: 4)
Role.create(role_type: :renting_manager, group_uid: 5)
Role.create(role_type: :main_bartender, group_uid: 6)
Role.create(role_type: :treasurer)
Role.create(role_type: :renting_manager)
Role.create(role_type: :main_bartender)
# rubocop:enable Rails/Output
