FactoryBot.define do
  factory :credit_mutation do
    description { Faker::Space.agency }
    user
    created_by factory: %i[user]
    amount { rand(0..100) }
  end
end
