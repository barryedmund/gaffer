Rails.application.routes.draw do
  resources :teams do
  	resources :team_players
  end

  resources :users
  resources :user_sessions, only: [:new, :create]

  root 'users#index'
end
