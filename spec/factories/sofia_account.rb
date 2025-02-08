FactoryBot.define do
  factory :sofia_account do
    username { Faker::Internet.username }
    password { Faker::Internet.password(min_length: 12, max_length: 30) }
    user { create(:user, :sofia_account) }

    trait :otp_enabled do
      otp_enabled { true }
    end
  end
end
