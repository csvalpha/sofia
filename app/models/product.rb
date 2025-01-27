class Product < ApplicationRecord
  enum category: { beer: 0, low_alcohol_beer: 9, craft_beer: 6, non_alcoholic: 1, distilled: 2, whiskey: 8, wine: 3, food: 4, tobacco: 5,
                   donation: 7 }

  has_many :product_prices, dependent: :destroy
  has_many :price_lists, through: :product_prices, dependent: :restrict_with_error

  validates :name, :category, presence: true

  accepts_nested_attributes_for :product_prices, allow_destroy: true

  def requires_age
    %w[beer craft_beer distilled whiskey wine tobacco].include? category
  end

  def t_category
    I18n.t category
  end
end
