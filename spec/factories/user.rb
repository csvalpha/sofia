FactoryBot.define do
  factory :user do
    name { Faker::StarWars.character }
  end
end
