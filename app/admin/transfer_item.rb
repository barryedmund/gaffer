ActiveAdmin.register TransferItem do
  permit_params :transfer_id, :sending_team_id, :receiving_team_id, :transfer_item_type, :team_player_id, :cash_cents

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :transfer, :collection => Transfer.all.map{ |transfer| ["#{transfer.id}: #{transfer.primary_team.title} and #{transfer.secondary_team.title}", transfer.id]}
      f.input :sending_team, :collection => Team.all.map{ |team| ["#{team.title} (#{team.league.name})", team.id]}
      f.input :receiving_team, :collection => Team.all.map{ |team| ["#{team.title} (#{team.league.name})", team.id]}
      f.input :transfer_item_type, :collection => ["cash", "player"]
      f.input :team_player, :collection => TeamPlayer.all.map{ |team_player| ["#{team_player.player.full_name} (#{team_player.team.title} / #{team_player.team.league.name})", team_player.id]}
      f.input :cash_cents
    end
    f.actions
  end
end
