FactoryGirl.define do
	factory :user do
		first_name "First"
		last_name "Last"
		sequence(:email) { |n| "user#{n}@gaffer.com"}
		password "gaffer123"
		password_confirmation "gaffer123"
	end
	
	factory :league do
    	name "MyLeague"
    	user
  	end

  	factory :team do
		title "Fantasy Playas"
		user
		league
	end

	factory :team_player do
	    team
	    player
	    squad_position
  	end

  	factory :player do
	    first_name "Paul"
		last_name "Pogba"
  	end

  	factory :squad_position do
    	short_name "SUB"
  	end

  	factory :game_week do
    	season
    	starts_at Time.new - 100
    	ends_at Time.new + 100
  	end
  	
  	factory :player_game_week do
  		player
  		game_week
  		minutes_played 90
  	end

	factory :season do
	    description "2015/16"
		starts_at "2015-11-04 21:58:20"
		ends_at "2015-11-04 21:58:20"
  	end 
end
