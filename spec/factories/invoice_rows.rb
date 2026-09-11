FactoryBot.define do
  factory :invoice_row do
    invoice

    sequence(:name) { |n| "#{Faker::Book.title} #{n}" }
    amount { rand(1...5) }
    price { rand(0..5.00) }
  end
end
