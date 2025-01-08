def seed_products # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:disable Style/WordArray
  products_beer = ['Bier (glas)', 'Bier (pul)', 'Bier (pitcher)', '12+1']
  products_low_alcohol_beer = ['Alcoholarm bier', 'Radler 0.0']
  products_craft_beer = ['Speciaalbier', 'Speciaalbier (pul)']
  products_non_alcoholic = ['Fris', 'Fris (klein)', 'Red Bull']
  products_distilled = ['Sterke drank', 'Weduwe Joustra Beerenburg']
  products_whiskey = ['Whiskey', 'Dure Whisky']
  products_wine = ['Wijn (glas)', 'Wijn (fles)']
  products_food = ['Tosti', 'Nootjes', 'Chips']
  products_tobacco = ['Sigaar', 'Sigaar (duur)']
  products_donation = ['Donatie']
  # rubocop:enable Style/WordArray

  products = products_beer.map do |name|
    Product.create(name: name, category: :beer)
  end

  products_low_alcohol_beer.each do |name|
    products << Product.create(name: name, category: :low_alcohol_beer)
  end

  products_craft_beer.each do |name|
    products << Product.create(name: name, category: :craft_beer)
  end

  products_non_alcoholic.each do |name|
    products << Product.create(name: name, category: :non_alcoholic)
  end

  products_distilled.each do |name|
    products << Product.create(name: name, category: :distilled)
  end

  products_whiskey.each do |name|
    products << Product.create(name: name, category: :whiskey)
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

  products_donation.each do |name|
    products << Product.create(name: name, category: :donation)
  end

  products
end
