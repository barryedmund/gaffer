ActiveAdmin.register GameWeek do
	permit_params :player_id
	
	index do
		selectable_column
		column :id
		column :player
		actions
	end

	form do |f|
		f.input :player
		f.actions
	end
end
