FactoryGirl.define do
  factory :credit_mutation do
    description { Faker::Space.agency }
    user
    amount { rand(0..100) }
  end
end
