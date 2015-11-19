ActiveAdmin.register PlayerGameWeek do
	permit_params :game_week_id, :player_id, :minutes_played

	index do
		selectable_column
		column :id
		column :game_week
		column :player
		column :minutes_played
		actions
	end

	form do |f|
	  f.semantic_errors
	  f.inputs do
	  	f.input :game_week, :collection => GameWeek.joins(:season).pluck(:id, :id ) 
	  	f.input :player
	  	f.input :minutes_played
	  end
	  f.actions
	end
end
