class ProductPolicy < ApplicationPolicy
  def create?
    user&.treasurer?
  end

  def update?
    create?
  end

  def permitted_attributes
    [
      :name, :category, :color, :requires_age, :id,
      { product_prices_attributes: %i[id product_id price_list_id price _destroy] }
    ]
  end
end
