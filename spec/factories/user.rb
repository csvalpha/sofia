FactoryBot.define do
  factory :user do
    name { Faker::Movies::StarWars.character }

    sequence(:email) { |n| Faker::Internet.email(name: "#{Faker::Internet.user_name}#{n}") }

    trait(:treasurer) do
      after :create do |user, _evaluator|
        user.roles = [FactoryBot.create(:role, role_type: :treasurer)]
      end
    end

    trait(:main_bartender) do
      after :create do |user, _evaluator|
        user.roles = [FactoryBot.create(:role, role_type: :main_bartender)]
      end
    end

    trait(:renting_manager) do
      after :create do |user, _evaluator|
        user.roles = [FactoryBot.create(:role, role_type: :renting_manager)]
      end
    end

    trait(:from_amber) do
      provider { 'amber_oauth2' }
    end

    trait(:sofia_account) do
      provider { 'sofia_account' }
    end

    trait(:manual) do
      provider { nil }
    end
  end
end
