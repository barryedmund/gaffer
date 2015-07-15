Rails.application.routes.draw do
  resources :teams

  resources :users
  resources :user_sessions, only: [:new, :create]

  root 'users#index'
end
