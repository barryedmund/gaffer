Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  resources :teams do
  	resources :team_players
  end

  resources :users
  resources :user_sessions, only: [:new, :create]

  root 'users#index'
end
