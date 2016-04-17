ActiveAdmin.register GameRound do
	permit_params :game_round_number, :league_season_id

	index do
		selectable_column
		column :id
		column :game_round_number
		column 'Season' do |gr|
			gr.league_season.season.description
		end
		column 'League' do |gr|
			gr.league_season.league.name
		end
		actions
	end

	form do |f|
		f.semantic_errors
  	f.inputs do
			f.input :league_season, :collection => LeagueSeason.pluck( :id, :id )
			f.input :game_round_number
		end
		f.actions
	end
end
