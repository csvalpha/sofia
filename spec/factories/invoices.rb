FactoryBot.define do
  factory :invoice do
    user
    association :activity, factory: [:activity, :manually_locked]
  end
end
