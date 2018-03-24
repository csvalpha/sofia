class Product < ApplicationRecord
  enum category: %i[beer non_alcoholic distilled wine food tobacco]

  has_many :product_prices, dependent: :destroy
  has_many :price_lists, through: :product_prices, dependent: :restrict_with_error

  validates :name, :category, presence: true

  accepts_nested_attributes_for :product_prices

  def requires_age?
    %w[beer distilled wine tobacco].include? category
  end

  def t_category
    I18n.t category
  end
end
