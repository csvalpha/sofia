FactoryGirl.define do
  factory :product do
    name { Faker::Book.title }
    requires_age { false }
  end
end
