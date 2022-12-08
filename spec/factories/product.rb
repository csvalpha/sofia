FactoryBot.define do
  factory :product do
    name { Faker::Book.title }
    category { %i[beer craft_beer non_alcoholic distilled wine food tobacco].sample }
  end
end
