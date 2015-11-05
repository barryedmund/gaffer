ActiveAdmin.register GameWeek do
	permit_params :player_id, :season
	
	index do
		selectable_column
		column :id
		column :player
		column :season
		actions
	end

	form do |f|
		f.input :player
		f.input :season, :collection => Season.pluck( :description, :id )
		f.actions
	end
end
