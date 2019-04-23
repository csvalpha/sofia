FactoryBot.define do
  factory :user do
    name { Faker::Movies::StarWars.character }

    trait(:treasurer) {
      after :create do |user, evaluator|
        user.roles = [FactoryBot.create(:role, role_type: :treasurer)]
      end
    }

    trait(:main_bartender) {
      after :create do |user, evaluator|
        user.roles = [FactoryBot.create(:role, role_type: :main_bartender)]
      end
    }
  end
end
