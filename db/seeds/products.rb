def seed_products # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # Category colors for products
  category_colors = {
    beer: '#FFD700', # Goud/geel - bierkleur
    low_alcohol_beer: '#90EE90', # Lichtgroen - light/gezonder
    craft_beer: '#CD7F32',     # Brons - premium/craft
    non_alcoholic: '#87CEEB',  # Lichtblauw - fris/water
    distilled: '#DC143C',      # Donkerrood - sterke drank
    whiskey: '#8B4513',        # Bruin - whiskykleur
    wine: '#722F37',           # Bordeaux - wijnkleur
    food: '#FFA500',           # Oranje - eten
    tobacco: '#808080',        # Grijs - rook
    donation: '#9370DB'        # Paars - speciaal/donatie
  }.freeze
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
    Product.create(name:, category: :beer, color: category_colors[:beer])
  end

  products_low_alcohol_beer.each do |name|
    products << Product.create(name:, category: :low_alcohol_beer, color: category_colors[:low_alcohol_beer])
  end

  products_craft_beer.each do |name|
    products << Product.create(name:, category: :craft_beer, color: category_colors[:craft_beer])
  end

  products_non_alcoholic.each do |name|
    products << Product.create(name:, category: :non_alcoholic, color: category_colors[:non_alcoholic])
  end

  products_distilled.each do |name|
    products << Product.create(name:, category: :distilled, color: category_colors[:distilled])
  end

  products_whiskey.each do |name|
    products << Product.create(name:, category: :whiskey, color: category_colors[:whiskey])
  end

  products_wine.each do |name|
    products << Product.create(name:, category: :wine, color: category_colors[:wine])
  end

  products_food.each do |name|
    products << Product.create(name:, category: :food, color: category_colors[:food])
  end

  products_tobacco.each do |name|
    products << Product.create(name:, category: :tobacco, color: category_colors[:tobacco])
  end

  products_donation.each do |name|
    products << Product.create(name:, category: :donation, color: category_colors[:donation])
  end

  products
end
