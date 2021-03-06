FactoryBot.define do
  factory :achievement do
  end

	factory :competition do
	  country_code { "en" }
		description {"Premier League"}
		game_weeks_per_season {38}
 	end

  factory :contract do
    weekly_salary_cents {1000000}
    starts_at {Date.today - 1}
    ends_at {Date.today + 400}
    team {Team.last}
  end

 	factory :game do
		game_week
		association :home_team, factory: :team
  	association :away_team, factory: :team, league_id: 1
  end

	factory :game_round do
		league_season
  end

  factory :game_week do
  	starts_at {Date.today}
  	ends_at {Date.today + 7.days}
    game_week_number {1}
	end

  factory :league do
  	name {"MyLeague"}
  	user
  	competition
  end

  factory :league_invite do
    league
    sequence(:email) { |n| "user#{n}@gaffer.com"}
  end

  factory :league_season do
    league
    season
  end

  factory :news_item do
    league
    news_item_resource_type {"Player"}
    news_item_resource_id {1}
  end

  factory :player do
    competition
    first_name {"Paul"}
		last_name {"Pogba"}
    playing_position {"Midfielder"}
    pl_player_code {12345}
    game_week_deadline_at {Time.now + 2.days}
    available {true}
	end

	factory :player_game_week do
		player
    game_week
		minutes_played {90}
	end

	factory :player_lineup do
		team
		player_game_week
		squad_position
  end

  factory :season do
	  description {"2015/16"}
		starts_at {Date.today - 1}
    ends_at {Date.today + 270.days}
		competition
  end

  factory :squad_position do
  	short_name {"SUB"}
    long_name {"Substitute"}
	end

  factory :midfielder_squad_position, :parent => :squad_position do
    short_name {"MD"}
    long_name {"Midfielder"}
  end

  factory :stadium do
    capacity {10000}
    name {"Gaffer Park"}
  end

  factory :team, aliases: [:home_team, :away_team, :primary_team, :secondary_team, :sending_team, :receiving_team] do
		title {"Fantasy Playas"}
		user
		league
    cash_balance_cents {200000000}
	end

  factory :team_achievement do
  end

	factory :team_player do
    team
    player
    squad_position
    trait :with_contract do
      after :create do |team_player|
        FactoryBot.create :contract, {team_player: team_player, team: team_player.team, weekly_salary_cents: 100000, signed: true, player: team_player.player}
      end
    end
	end

	factory :transfer do
		association :primary_team, factory: :team
  	association :secondary_team, factory: :team
  	primary_team_accepted {true}
  	secondary_team_accepted {false}
	end

  factory :transfer_item do
    transfer
    transfer_item_type {""}
    association :sending_team, factory: :team
    association :receiving_team, factory: :team
    team_player
    cash_cents {100000000}
  end

	factory :user do
		first_name {"First"}
		last_name {"Last"}
		sequence(:email) { |n| "user#{n}@gaffer.com"}
		password {"gaffer123"}
		password_confirmation {"gaffer123"}
	end
end
