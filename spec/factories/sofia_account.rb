FactoryBot.define do
  factory :sofia_account do
    sequence(:username) { |n| "#{Faker::Internet.username} #{n}" }
    password { Faker::Internet.password(min_length: 12, max_length: 30) }
    user factory: %i[user sofia_account]

    trait :otp_enabled do
      otp_enabled { true }
    end
  end
end
