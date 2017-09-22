FactoryGirl.define do
  factory :user do
    username { Faker::StarWars.character }
  end
end
