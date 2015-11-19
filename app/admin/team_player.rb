ActiveAdmin.register TeamPlayer do
	permit_params :player_id, :team_id, :first_team

	index do
		selectable_column
		column :id
		column :player
		column :team
		actions
	end

	form do |f|
	  f.semantic_errors
	  f.inputs do
	  	f.input :team
	  	f.input :player
	  	f.input :squad_position, :collection => SquadPosition.pluck( :short_name, :id )
	  end
	  f.actions
	end
end
