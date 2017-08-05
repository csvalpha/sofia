FactoryGirl.define do
  factory :transaction do
    timestamp { Time.zone.now }
    amount { rand(0..250.0) }
    product
    activity
  end
end
