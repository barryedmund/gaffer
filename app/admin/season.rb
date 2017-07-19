ActiveAdmin.register Season do
	permit_params :competition_id, :description, :starts_at, :ends_at, :is_completed

	index do
    column :id
    column :competition
    column :description
    column :starts_at
    column :ends_at
    column :is_completed
    actions
  end

	form do |f|
		f.semantic_errors
	  	f.inputs do
			f.input :competition, :collection => Competition.pluck( :description, :id )
			f.input :description
			f.input :starts_at
			f.input :ends_at
			f.input :is_completed
		end
		f.actions
	end
end
