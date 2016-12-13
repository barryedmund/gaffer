ActiveAdmin.register PlayerLineup do
  permit_params :team_id, :player_game_week_id, :squad_position_id

  index do
    selectable_column
    column :id
    column :team
    column :player do |player_lineup|
      player_lineup.player_game_week.player.full_name
    end
    column :game_week  do |player_lineup|
      player_lineup.player_game_week.game_week.game_week_number
    end
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :team
      # f.input :player_game_week
      f.input :player_game_week, collection: PlayerGameWeek.order(:player_id, :game_week_id).all.map{ |pgw| ["#{pgw.player.full_name} (#{pgw.game_week.game_week_number})", pgw.id]}
      f.input :squad_position, collection: SquadPosition.pluck( :short_name, :id )
    end
    f.actions
  end

  filter :team

end
