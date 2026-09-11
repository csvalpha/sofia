FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "#{Faker::Book.title} #{n}" }
    category { %i[beer low_alcohol_beer craft_beer non_alcoholic distilled whiskey wine food tobacco donation].sample }
  end
end
