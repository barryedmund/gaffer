ActiveAdmin.register Competition do
	permit_params :country_code, :description, :game_weeks_per_season
end
