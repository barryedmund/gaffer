ActiveAdmin.register PlayerLineup do

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

  filter :team

end
