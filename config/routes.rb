Rails.application.routes.draw do

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get "" => "news_items#index"
  get "/login" => "user_sessions#new", as: :login
  delete "/logout" => "user_sessions#destroy", as: :logout
  get "/signup" => "users#new", as: :signup

  resources :users
  resources :user_sessions, only: [:new, :create]
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :leagues do
    resources :teams do
      member do
        get :display
      end
    	resources :team_players do
    		member do
    			patch :update_first_team
          patch :release
    		end
    	end
      resources :team_achievements
    end
    resources :players do
      resources :game_weeks
    end
    resources :games, only: [:index, :show]
    resources :transfers do
      member do
        patch :change_response
      end
      resources :transfer_items
    end
    resources :league_seasons, only: [:new, :create]
    resources :league_invites
    resources :contracts
  end
  resources :player_game_weeks
  resources :game_rounds
  resources :news_items

  root 'news_items#index'
end
