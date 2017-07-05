Rails.application.routes.draw do
  resources :activities, only: %i[index show create update destroy]
end
