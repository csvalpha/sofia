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
    resources :product_price_folders, only: %i[index create] do
      collection do
        patch :reorder
      end
    end
    resources :product_prices, only: [] do
      collection do
        patch :reorder
      end
    end
  end

  resources :product_price_folders, only: %i[update destroy]
  resources :product_prices, only: [] do
    member do
      patch :assign_folder
    end
  end

  resources :users, only: %i[index show create update] do
    collection do
      post :search
    end
    member do
      get :activities
      get :json
      patch :update_with_sofia_account
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

  resources :sofia_accounts, only: %i[create] do
    collection do
      get :login
      get :activate_account
      get :new_activation_link
      get :forgot_password, as: :forgot_password_view, action: :forgot_password_view
      post :forgot_password
    end
    member do
      get :reset_password, as: :reset_password_view, action: :reset_password_view
      patch :reset_password
      patch :update_password
      patch :enable_otp
      patch :disable_otp
    end
  end

  devise_scope :user do
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  # Sidekiq dashboard
  require 'sidekiq/web'
  require 'sidekiq-scheduler/web'

  authenticate :user, lambda(&:treasurer?) do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: 'index#index'

  get '/403', to: 'errors#forbidden'
  get '/404', to: 'errors#not_found'
  get '/406', to: 'errors#unacceptable'
  get '/422', to: 'errors#unprocessable_entity'
  get '/500', to: 'errors#internal_server_error'
end
