ActiveAdmin.register GameWeek do
	permit_params :league_season_id, :starts_at, :ends_at
	
	index do
		selectable_column
		column :id
		column "League" do |gw|
			gw.league_season.league.name
		end
		column "Season" do |gw|
			gw.league_season.season.description
		end
		column :starts_at
		column :ends_at
		actions
	end

	form do |f|
		f.semantic_errors
	  	f.inputs do
			f.input :league_season
			f.input :starts_at
			f.input :ends_at
		end
		f.actions
	end
end
