Rails.application.routes.draw do
  resources :game_rounds

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get "/login" => "user_sessions#new", as: :login
  delete "/logout" => "user_sessions#destroy", as: :logout
  get "/signup" => "users#new", as: :signup

  resources :users
  resources :user_sessions, only: [:new, :create]
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :leagues do
    resources :teams do
    	resources :team_players do
        resources :players do
          resources :game_weeks
        end
    		member do
    			patch :update_first_team
    		end
    	end
    end
    resources :games, only: [:index, :show]
  end
  resources :player_game_weeks
  
  root 'leagues#index'
end
