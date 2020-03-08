FactoryBot.define do
  factory :invoice do
    user
    association :activity, factory: %i[activity manually_locked]
  end
end
