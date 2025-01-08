class PriceList < ApplicationRecord
  has_many :product_price, dependent: :destroy
  has_many :products, through: :product_price, dependent: :restrict_with_exception
  has_many :activities, dependent: :restrict_with_exception

  validates :name, presence: true

  scope :unarchived, -> { where(archived_at: nil) }

  def product_price_for(product)
    @product_price ||= ProductPrice.includes(:product).where(price_list: self)
    @product_price.find { |pp| pp.product == product }
  end

  def to_s
    name
  end
end
