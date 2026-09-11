FactoryBot.define do
  factory :credit_mutation do
    sequence(:description) { |n| "#{Faker::Space.agency} #{n}" }
    user
    created_by factory: %i[user]
    amount { rand(0..100) }
  end
end
