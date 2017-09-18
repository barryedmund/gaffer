ActiveAdmin.register User do
	permit_params :first_name, :last_name, :email, :last_seen_at

	index do
		selectable_column
		column :id
		column :first_name
		column :last_name
		column :email
    column :last_seen_at
		actions
	end
end
