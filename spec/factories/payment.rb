FactoryBot.define do
  factory :payment do
    mollie_id { Faker::Name.initials(number: 4) }
    amount { rand(20..1000) }
    status { 'open' }
    user

    trait(:invoice) do
      user { nil }
      invoice
    end
  end
end
