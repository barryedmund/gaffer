ActiveAdmin.register GameWeek do
	permit_params :season_id, :starts_at, :ends_at
	
	index do
		selectable_column
		column :id
		column :season do |gw|
			gw.season.description
		end
		actions
	end

	form do |f|
		f.semantic_errors
	  	f.inputs do
			f.input :season, :collection => Season.pluck( :description, :id )
			f.input :starts_at
			f.input :ends_at
		end
		f.actions
	end
end
