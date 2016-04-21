Rails.application.routes.draw do

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
        resources :contracts
        resources :players do
          resources :game_weeks
        end
    		member do
    			patch :update_first_team
    		end
    	end
    end
    resources :games, only: [:index, :show]
    resources :transfers do
      member do
        patch :change_response
      end
      resources :transfer_items
    end
    resources :league_seasons, only: [:new, :create]
  end
  resources :player_game_weeks
  resources :game_rounds
  
  root 'leagues#index'
end
