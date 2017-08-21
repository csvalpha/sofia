FactoryGirl.define do
  factory :product do
    name { Faker::Book.title }
  end
end
