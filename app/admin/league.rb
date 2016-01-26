ActiveAdmin.register League do
	permit_params :name, :team_id, :user_id, :competition_id
	index do
		selectable_column
		column :id
		column :name
		column :user
		actions
	end

	form do |f|
	  f.semantic_errors
	  f.inputs do
	  	f.input :name
	  	f.input :user, :collection => User.pluck( :email, :id )
	  	f.input :competition, :collection => Competition.pluck( :description, :id )
	  end
	  f.actions
	end
end
