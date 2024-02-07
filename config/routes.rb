Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'callbacks' }

  resources :activities, only: %i[index show create update destroy] do
    member do
      get :order_screen
      get :sumup_callback
      get :product_totals
      post :lock
      post :create_invoices
    end
  end

  resources :orders, only: %i[index create update destroy]
  resources :price_lists, only: %i[index create update] do
    member do
      post :archive
      post :unarchive
    end
  end

  resources :users, only: %i[index show create update] do
    collection do
      get :refresh_user_list
      post :search
    end
    member do
      get :activities
      get :json
    end
  end

  resources :products, only: %i[create update], defaults: { format: :json }
  resources :credit_mutations, only: %i[index create]
  resources :invoices, only: %i[index show create] do
    member do
      get :pay
      post :send_invoice
    end
  end
  resources :zatladder, only: %i[index]
  resources :finance_overview, only: %i[index]
  resources :payments, only: %i[index create] do
    member do
      get :callback
    end
    collection do
      get :add
    end
  end

  devise_scope :user do
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  # Sidekiq dashboard
  require 'sidekiq/web'
  require 'sidekiq-scheduler/web'

  authenticate :user, ->(u) { u.treasurer? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: 'index#index'

  get '/403', to: 'errors#forbidden'
  get '/404', to: 'errors#not_found'
  get '/422', to: 'errors#unacceptable'
  get '/500', to: 'errors#internal_server_error'
end
