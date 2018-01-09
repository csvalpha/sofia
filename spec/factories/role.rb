FactoryBot.define do
  factory :role do
    role_type { %i[treasurer main_bartender].sample }
    group_uid { rand(0..100) }
  end
end
