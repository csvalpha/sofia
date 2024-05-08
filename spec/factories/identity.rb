FactoryBot.define do
  factory :identity do
    username { Faker::Internet.username }
    password { Faker::Internet.password(min_length: 12, max_length: 30) }
    user { create(:user, :identity) }

    trait :otp_enabled do
      otp_enabled { true }
    end
  end
end
