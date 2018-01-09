Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'callbacks' }

  resources :activities, only: %i[index show create update] do
    resources :orders, only: %i[index create]
  end

  resources :price_lists, only: %i[index create update]

  resources :users, only: %i[index show create] do
    collection do
      get :refresh_user_list
      post :search
    end
  end

  resources :products, only: %i[index show create update], defaults: { format: :json }
  resources :credit_mutations, only: %i[index create]
  resources :product_price, only: %i[destroy]

  devise_scope :user do
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  root to: 'index#index'

  get '403', to: 'errors#forbidden'
  get '404', to: 'errors#not_found'
  get '422', to: 'errors#unacceptable'
  get '500', to: 'errors#internal_server_error'
end
