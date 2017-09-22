Rails.application.routes.draw do
  get "/", to: 'index#index'
  resources :activities, only: %i[index show create update destroy]
end
