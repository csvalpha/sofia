FactoryBot.define do
  factory :role do
    role_type { %i[treasurer main_bartender renting_manager].sample }
    group_uid { rand(1...100) }
  end
end
