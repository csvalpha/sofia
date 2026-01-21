class ProductPrice < ApplicationRecord
  acts_as_paranoid

  belongs_to :product
  belongs_to :price_list
  belongs_to :product_price_folder, optional: true

  validates :price, presence: true, inclusion: { in: 0..100 }
  validates :product_id, uniqueness: { scope: %i[price_list_id deleted_at] }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  delegate :name, to: :product

  default_scope { order(:position) }

  before_validation :set_default_position, on: :create

  # Scope for products without a folder (shown on home screen)
  scope :without_folder, -> { where(product_price_folder_id: nil) }

  # Scope for products in a specific folder
  scope :in_folder, ->(folder) { where(product_price_folder: folder) }

  private

  def set_default_position
    return if position.present? && position > 0

    scope = price_list&.product_price&.where(product_price_folder_id: product_price_folder_id)
    max_position = scope&.maximum(:position) || -1
    self.position = max_position + 1
  end
end
