FactoryBot.define do
  factory :user do
    name { Faker::Movies::StarWars.character }

    sequence(:email) { |n| Faker::Internet.safe_email(name: "#{Faker::Internet.user_name}#{n}") }

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
  end
end
