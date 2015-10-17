ActiveAdmin.register Team do
	permit_params :title, :user_id

	index do
		selectable_column
		column :id
		column :title
		column :user
		column :league
		actions
	end

	form do |f|
	  f.semantic_errors
	  f.inputs do
	  	f.input :title
	  	f.input :user, :collection => User.pluck( :email, :id )
	  end
	  f.actions
	end
end
