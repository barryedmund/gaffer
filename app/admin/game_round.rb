ActiveAdmin.register GameRound do
	permit_params :game_round_number, :season_id, :league_id

	index do
		selectable_column
		column :id
		column :game_round_number
		column :season do |gr|
			gr.season.description
		end
		column :league do |gr|
			gr.league.name
		end
		actions
	end

	form do |f|
		f.semantic_errors
  	f.inputs do
			f.input :season, :collection => Season.pluck( :description, :id )
			f.input :league, :collection => League.pluck( :name, :id )
			f.input :game_round_number
		end
		f.actions
	end
end
