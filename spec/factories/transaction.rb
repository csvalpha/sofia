FactoryGirl.define do
  factory :transaction do
    timestamp { Time.zone.now }
    amount { rand(0..25.0) }
    product
    activity
    user
  end
end
