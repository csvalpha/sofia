def seed_products # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  products = []

  # rubocop:disable Style/WordArray
  products_beer = ['Bier (glas)', 'Bier (pul)', 'Bier (pitcher)', 'Speciaalbier', '12+1']
  products_non_alcoholic = ['Fris', 'Fris (klein)', 'Red Bull']
  products_distilled = ['Sterke drank', 'Dure Whisky', 'Weduwe Joustra Beerenburg']
  products_wine = ['Wijn (glas)', 'Wijn (fles)']
  products_food = ['Tosti', 'Nootjes', 'Chips']
  products_tobacco = ['Sigaar', 'Sigaar (duur)']
  # rubocop:enable Style/WordArray

  products_beer.each do |name|
    products << Product.create(name: name, category: :beer)
  end

  products_non_alcoholic.each do |name|
    products << Product.create(name: name, category: :non_alcoholic)
  end

  products_distilled.each do |name|
    products << Product.create(name: name, category: :distilled)
  end

  products_wine.each do |name|
    products << Product.create(name: name, category: :wine)
  end

  products_food.each do |name|
    products << Product.create(name: name, category: :food)
  end

  products_tobacco.each do |name|
    products << Product.create(name: name, category: :tobacco)
  end

  products
end
