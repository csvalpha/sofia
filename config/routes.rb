Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'callbacks' }

  resources :activities, only: %i[index show create update destroy] do
    resources :orders, only: %i[index new create destroy]
  end

  resources :price_lists, only: %i[index show create update destroy] do
    get :autocomplete_price_list_name, on: :collection
  end

  resources :users, only: %i[index show create update destroy] do
    collection do
      get :refresh_user_list
    end
  end

  resources :products, only: %i[index show create update destroy], defaults: { format: :json }
  resources :credit_mutations, only: %i[create]
  resources :product_price, only: %i[show update]

  devise_scope :user do
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  root to: 'index#index'
end
