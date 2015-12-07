ActiveAdmin.register Game do
	permit_params :home_team_id, :away_team_id, :game_week_id

	index do
		selectable_column
		column :id
		column :home_team
		column :away_team
		column :game_week
		actions
	end

	form do |f|
	  f.semantic_errors
	  f.inputs do
	  	f.input :home_team, :collection => Team.all.map{ |team| ["#{team.title} (#{team.league.name})", team.id]}
	  	f.input :away_team, :collection => Team.all.map{ |team| ["#{team.title} (#{team.league.name})", team.id]}
	  	f.input :game_week, :collection => GameWeek.all.map{ |gw| ["Game week ##{gw.id} (#{gw.season.description})", gw.id]}
	  end
	  f.actions
	end
end
