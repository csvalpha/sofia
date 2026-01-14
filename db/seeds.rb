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
# Nederlandse testnamen
dutch_names = [
  'Jan de Vries',
  'Piet Bakker',
  'Lisa Jansen',
  'Emma van der Berg',
  'Daan Visser',
  'Sophie Smit',
  'Thomas Mulder',
  'Anna de Boer'
]

users = dutch_names.map do |name|
  FactoryBot.create(:user, name:)
end
users << FactoryBot.create(:user, name: 'Benjamin Knopje', birthday: 16.years.ago)

p 'Seeding activities...'
# Recente activiteiten
activity_names = %w[Donderdagborrel Vrijdagborrel ALV Kerstdiner Filmavond Bierproeverij]
activities = activity_names.map do |title|
  FactoryBot.create(:activity, title:, price_list: price_lists.sample, created_by: users.sample)
end

# Historische activiteiten (locked)
p 'Seeding historical activities...'
historical_activities = [
  { title: 'Nieuwjaarsborrel', days_ago: 15 },
  { title: 'Studiemiddag', days_ago: 30 },
  { title: 'Kroegentocht', days_ago: 45 },
  { title: 'Dies Natalis', days_ago: 90 }
]

historical_activities.each do |hist_act|
  start_time = hist_act[:days_ago].days.ago.beginning_of_hour
  end_time = (hist_act[:days_ago] - 1).days.ago.beginning_of_hour
  activity = FactoryBot.create(:activity,
                               title: hist_act[:title],
                               start_time:,
                               end_time:,
                               price_list: price_lists.sample,
                               created_by: users.sample)
  activities << activity
end

p 'Seeding orders...'
activities.each do |activity|
  5.times do
    FactoryBot.create(:order, :with_items, products: activity.products.sample(2), activity:,
                                           user: users.sample, created_by: users.sample)
  end
end

p 'Seeding credit mutations...'
# Realistische credit mutations met variatie
mutation_descriptions = [
  { description: 'Opwaardering', amount_range: 10..50 },
  { description: 'Contant gestort', amount_range: 5..30 },
  { description: 'iDEAL betaling', amount_range: 10..100 },
  { description: 'Correctie admin', amount_range: -20..20 },
  { description: 'Restitutie borrel', amount_range: 5..15 },
  { description: 'Handmatige correctie', amount_range: -10..10 }
]

users.each do |user|
  3.times do
    mutation = mutation_descriptions.sample
    amount = rand(mutation[:amount_range])
    FactoryBot.create(:credit_mutation,
                      user:,
                      created_by: users.sample,
                      description: mutation[:description],
                      amount:,
                      activity: (activities + [nil]).sample)
  end
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

p 'Seeding Sofia accounts...'
# Use environment variable for password or fallback to default for development

treasurer_user = FactoryBot.create(:user, :sofia_account, name: 'Penningmeester Test')
SofiaAccount.create!(username: 'penningmeester', password: 'password1234', user: treasurer_user)
treasurer_role = Role.create(role_type: :treasurer)
treasurer_user.roles << treasurer_role

main_bartender_user = FactoryBot.create(:user, :sofia_account, name: 'Hoofdtapper Test')
SofiaAccount.create!(username: 'hoofdtapper', password: 'password1234', user: main_bartender_user)
main_bartender_role = Role.create(role_type: :main_bartender)
main_bartender_user.roles << main_bartender_role

renting_manager_user = FactoryBot.create(:user, :sofia_account, name: 'Verhuur Test')
SofiaAccount.create!(username: 'verhuur', password: 'password1234', user: renting_manager_user)
renting_manager_role = Role.create(role_type: :renting_manager)
renting_manager_user.roles << renting_manager_role
# rubocop:enable Rails/Output
