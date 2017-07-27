ActiveAdmin.register TeamPlayer do
	permit_params :player_id, :team_id, :first_team, :squad_position_id, :transfer_minimum_bid, :transfer_completes_at, :is_voluntary_transfer

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
		column "Squad Position"  do |team_player|
			team_player.squad_position.short_name
		end
		column :is_voluntary_transfer
		column :transfer_minimum_bid
		column :transfer_completes_at
		column 'Value' do |team_player|
      team_player.player.player_value
    end
    column 'League' do |team_player|
      team_player.team.league.name
    end
		actions
	end

	form do |f|
	  f.semantic_errors
	  f.inputs do
	  	f.input :team
	  	f.input :player
	  	f.input :squad_position, :collection => SquadPosition.pluck( :short_name, :id )
	  	f.input :is_voluntary_transfer
			f.input :transfer_minimum_bid
			f.input :transfer_completes_at
	  end
	  f.actions
	end

	csv do
    column :id
		column :team do |team_player|
			team_player.team.title
		end
		column :player do |team_player|
			team_player.player.full_name
		end
		column "Playing Position"  do |team_player|
			team_player.player.playing_position
		end
		column "Squad Position"  do |team_player|
			team_player.squad_position.short_name
		end
		column :is_voluntary_transfer
		column :transfer_minimum_bid
		column :transfer_completes_at
		column 'Value' do |team_player|
      team_player.player.player_value
    end
    column 'League' do |team_player|
      team_player.team.league.name
    end
  end
end
