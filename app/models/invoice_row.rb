class InvoiceRow < ApplicationRecord
  belongs_to :invoice

  validates :name, :amount, :price, presence: true

  def total
    amount * price
  end
end
