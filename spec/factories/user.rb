FactoryBot.define do
  factory :user do
    name { Faker::Movies::StarWars.character }
  end
end
