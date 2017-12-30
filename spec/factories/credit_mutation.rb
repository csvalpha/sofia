FactoryBot.define do
  factory :credit_mutation do
    description { Faker::Space.agency }
    user
    association :created_by, factory: :user
    amount { rand(0..100) }
  end
end
