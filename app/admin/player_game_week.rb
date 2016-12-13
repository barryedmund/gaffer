ActiveAdmin.register PlayerGameWeek do
	permit_params :game_week_id, :player_id, :minutes_played, :assists, :goals, :clean_sheet, :goals_conceded

	index do
		selectable_column
		column :id
		column :game_week do |player_game_week|
			player_game_week.game_week.game_week_number
		end
		column :player
		column :minutes_played
		column :goals
		column :assists
		column :clean_sheet
		column :goals_conceded
		actions
	end

	form do |f|
	  f.semantic_errors
	  f.inputs do
	  	f.input :game_week, :collection => GameWeek.order(:id).all.map{ |gw| ["#{gw.game_week_number} (#{gw.season.description})", gw.id]}
	  	f.input :player
	  	f.input :minutes_played
	  	f.input :goals
	  	f.input :assists
	  	f.input :goals_conceded
	  	f.input :clean_sheet
	  end
	  f.actions
	end
end
