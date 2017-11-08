FactoryGirl.define do
  factory :product do
    name { Faker::Book.title }
    contains_alcohol { Faker::Boolean.boolean }
  end
end
