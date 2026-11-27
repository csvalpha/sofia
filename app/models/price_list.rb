class PriceList < ApplicationRecord
  has_many :product_prices, dependent: :destroy
  has_many :products, through: :product_prices, dependent: :restrict_with_exception
  has_many :activities, dependent: :restrict_with_exception
  has_many :product_price_folders, dependent: :destroy

  validates :name, presence: true
  validates :grid_size, numericality: { only_integer: true, greater_than_or_equal_to: 2, less_than_or_equal_to: 9 }, allow_nil: true

  after_initialize :set_defaults, unless: :persisted?

  scope :unarchived, -> { where(archived_at: nil) }

  def product_price_for(product)
    @product_price ||= ProductPrice.includes(:product).where(price_list: self)
    @product_price.find { |pp| pp.product == product }
  end

  def to_s
    name
  end

  private

  def set_defaults
    self.grid_size ||= 4
  end
end
