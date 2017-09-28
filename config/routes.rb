Rails.application.routes.draw do
  resources :activities, only: %i[index show create update destroy]
  resources :price_lists, only: %i[index show create update destroy] do
    get :autocomplete_price_list_name, on: :collection
  end
  resources :products, only: %i[index show create update destroy]
  resources :users, only: %i[index show create update destroy]
  resources :credit_mutations, only: %i[index show create update destroy]

  root to: 'index#index'
end
