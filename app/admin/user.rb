ActiveAdmin.register User do
	index do
		column :first_name
		column :last_name
		column :email
		column :created_at
		column :updated_at
	end
end
