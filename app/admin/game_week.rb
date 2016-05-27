ActiveAdmin.register GameWeek do
	permit_params :season_id, :game_week_number, :starts_at, :ends_at
	
	index do
		selectable_column
		column :id
		column "Season" do |gw|
			gw.season.description
		end
		column :game_week_number
		column :starts_at
		column :ends_at
		actions
	end

	form do |f|
		f.semantic_errors
	  	f.inputs do
			f.input :season
			f.input :game_week_number
			f.input :starts_at
			f.input :ends_at
		end
		f.actions
	end
end
