FactoryGirl.define do
  factory :credit_mutation do
    description { Faker::Space.agency }
    user
    amount { rand(0..100) }
    activity if [true, false].sample
  end
end
