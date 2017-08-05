FactoryGirl.define do
  factory :product do
    title { Faker::Book.title }
  end
end
