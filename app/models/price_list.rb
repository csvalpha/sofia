class PriceList < ApplicationRecord
  has_many :product_price, dependent: :destroy
  has_many :products, through: :product_price, dependent: :restrict_with_exception
  has_many :activities, dependent: :restrict_with_exception

  validates :name, presence: true

  def product_price_for(product)
    product_price.select { |pp| pp.product == product }.first
  end

  # def activities
  #   Activity.where(price_list: self).order(:start_time)
  # end

  def to_s
    name
  end
end
