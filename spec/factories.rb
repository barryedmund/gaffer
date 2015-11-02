FactoryGirl.define do
	factory :squad_position do
    	short_name "SUB"
  	end
	
	factory :game_week do
    
  	end
 
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

	factory :player do
	    first_name "Paul"
		last_name "Pogba"
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
end
