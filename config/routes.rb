Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'callbacks' }

  resources :activities, only: %i[index show create update destroy] do
    resources :orders, only: %i[index new create destroy]
  end

  resources :price_lists, only: %i[index show create update destroy]

  resources :users, only: %i[index show create update destroy] do
    collection do
      get :refresh_user_list
      post :search
    end
  end

  resources :products, only: %i[index show create update destroy], defaults: { format: :json }
  resources :credit_mutations, only: %i[index create]
  resources :product_price, only: %i[destroy]

  devise_scope :user do
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  root to: 'index#index'
end
