FactoryBot.define do
  factory :product do
    name { Faker::Book.title }
    category { %i[beer low_alcohol_beer craft_beer non_alcoholic distilled whiskey wine food tobacco donation].sample }
  end
end
