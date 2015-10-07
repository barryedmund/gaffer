ActiveAdmin.register User do
	permit_params :first_name, :last_name, :email

	index do
		selectable_column
		column :id
		column :first_name
		column :last_name
		column :email
		actions
	end
end
