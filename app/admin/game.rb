ActiveAdmin.register Game do
	permit_params :home_team_id, :away_team_id, :game_week_id, :game_round_id, :home_team_score, :away_team_score

	index do
		selectable_column
		column :id
		column :home_team
		column :away_team
		column :home_team_score
		column :away_team_score
		column :game_week do |game|
			"#{game.game_week.starts_at}  -  #{game.game_week.ends_at}"
		end
		column :game_round do |game|
			if game.game_round
				"Game round ##{game.game_round.game_round_number}"
			end
		end
		column :league
		actions
	end

	form do |f|
	  f.semantic_errors
	  f.inputs do
	  	f.input :home_team, :collection => Team.all.map{ |team| ["#{team.title} (#{team.league.name})", team.id]}
	  	f.input :away_team, :collection => Team.all.map{ |team| ["#{team.title} (#{team.league.name})", team.id]}
	  	f.input :game_round, :collection => GameRound.all.map{ |gr| ["Round ##{gr.game_round_number} (#{gr.league_season.league.name} / #{gr.league_season.season.description})", gr.id]}
	  	f.input :home_team_score
	  	f.input :away_team_score
	  end
	  f.actions
	end
end
