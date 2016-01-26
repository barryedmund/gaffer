ActiveAdmin.register Season do
	permit_params :competition_id, :description, :starts_at, :ends_at

	form do |f|
		f.semantic_errors
	  	f.inputs do
			f.input :competition, :collection => Competition.pluck( :description, :id )
			f.input :description
			f.input :starts_at
			f.input :ends_at
		end
		f.actions
	end
end
