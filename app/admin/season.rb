ActiveAdmin.register Season do
	permit_params :description, :starts_at, :ends_at
end
