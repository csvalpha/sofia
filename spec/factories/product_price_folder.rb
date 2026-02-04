FactoryBot.define do
  factory :product_price_folder do
    price_list
    sequence(:name) { |n| "Folder #{n}" }
    sequence(:position) { |n| n }
    color { '#6c757d' }
  end
end
