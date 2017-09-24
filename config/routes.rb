Rails.application.routes.draw do
  resources :activities, only: %i[index show create update destroy]
  resources :price_lists, only: %i[index show create update destroy]
  resources :products, only: %i[index show create update destroy]
  resources :users, only: %i[index show create update destroy]

  root to: 'index#index'
end
