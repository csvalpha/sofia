class ProductPriceFolder < ApplicationRecord
  acts_as_paranoid

  belongs_to :price_list
  has_many :product_prices, dependent: :nullify

  validates :name, presence: true
  validates :color, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  default_scope { order(:position) }

  before_validation :set_default_position, on: :create

  private

  def set_default_position
    return if position.present? && position > 0

    max_position = price_list&.product_price_folders&.maximum(:position) || -1
    self.position = max_position + 1
  end
end
