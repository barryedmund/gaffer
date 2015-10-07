ActiveAdmin.register TeamPlayer do
	permit_params :player_id, :team_id, :first_team

	index do
		selectable_column
		column :id
		column :player
		column :team
		actions
	end
end
