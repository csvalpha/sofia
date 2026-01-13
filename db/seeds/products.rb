# Category colors for products
CATEGORY_COLORS = {
  beer: '#FFD700',           # Goud/geel - bier kleur
  low_alcohol_beer: '#90EE90', # Lichtgroen - light/gezonder
  craft_beer: '#CD7F32',     # Brons - premium/craft
  non_alcoholic: '#87CEEB',  # Lichtblauw - fris/water
  distilled: '#DC143C',      # Donkerrood - sterke drank
  whiskey: '#8B4513',        # Bruin - whiskey kleur
  wine: '#722F37',           # Bordeaux - wijn kleur
  food: '#FFA500',           # Oranje - eten
  tobacco: '#808080',        # Grijs - rook
  donation: '#9370DB'        # Paars - speciaal/donatie
}.freeze

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
    Product.create(name:, category: :beer, color: CATEGORY_COLORS[:beer])
  end

  products_low_alcohol_beer.each do |name|
    products << Product.create(name:, category: :low_alcohol_beer, color: CATEGORY_COLORS[:low_alcohol_beer])
  end

  products_craft_beer.each do |name|
    products << Product.create(name:, category: :craft_beer, color: CATEGORY_COLORS[:craft_beer])
  end

  products_non_alcoholic.each do |name|
    products << Product.create(name:, category: :non_alcoholic, color: CATEGORY_COLORS[:non_alcoholic])
  end

  products_distilled.each do |name|
    products << Product.create(name:, category: :distilled, color: CATEGORY_COLORS[:distilled])
  end

  products_whiskey.each do |name|
    products << Product.create(name:, category: :whiskey, color: CATEGORY_COLORS[:whiskey])
  end

  products_wine.each do |name|
    products << Product.create(name:, category: :wine, color: CATEGORY_COLORS[:wine])
  end

  products_food.each do |name|
    products << Product.create(name:, category: :food, color: CATEGORY_COLORS[:food])
  end

  products_tobacco.each do |name|
    products << Product.create(name:, category: :tobacco, color: CATEGORY_COLORS[:tobacco])
  end

  products_donation.each do |name|
    products << Product.create(name:, category: :donation, color: CATEGORY_COLORS[:donation])
  end

  products
end
