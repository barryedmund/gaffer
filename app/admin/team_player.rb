ActiveAdmin.register TeamPlayer do
	permit_params :player_id, :team_id, :first_team, :squad_position_id

	index do
		selectable_column
		column :id
		column :team
		column :player  do |team_player|
			team_player.player.full_name
		end
		column "Playing Position"  do |team_player|
			team_player.player.playing_position
		end
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
