FactoryBot.define do
  factory :invoice_row do
    invoice

    name { Faker::Book.title }
    amount { rand(1...5) }
    price { rand(0..5.00) }
  end
end
