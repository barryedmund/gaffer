ActiveAdmin.register PlayerGameWeek do
	permit_params :game_week_id, :player_id, :minutes_played, :assists

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
	  	f.input :game_week
	  	f.input :player
	  	f.input :minutes_played
	  	f.input :assists
	  end
	  f.actions
	end
end
