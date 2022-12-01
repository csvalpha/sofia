class Product < ApplicationRecord
  enum category: { beer: 0, craft_beer: 6, non_alcoholic: 1, distilled: 2, wine: 3, food: 4, tobacco: 5 }

  has_many :product_prices, dependent: :destroy
  has_many :price_lists, through: :product_prices, dependent: :restrict_with_error

  validates :name, :category, presence: true
  validate :name_readonly

  accepts_nested_attributes_for :product_prices, allow_destroy: true

  def requires_age
    %w[beer craft_beer distilled wine tobacco].include? category
  end

  def t_category
    I18n.t category
  end

  private

  def name_readonly
    return if new_record?

    errors.add(:name, 'is readonly') if name_changed?
  end
end
