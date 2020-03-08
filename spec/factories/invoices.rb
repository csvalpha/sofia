FactoryBot.define do
  factory :invoice do
    human_id { "20#{rand 10..50}00#{rand 10..99}" }
    user
    activity
    amount { rand(0..99.00) }
  end
end
