ActiveAdmin.register Competition do
	permit_params :country_code, :description, :rounds_per_season
end
