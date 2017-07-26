ActiveAdmin.register Player do
	permit_params :first_name, :last_name, :competition_id, :game_week_deadline_at

  index do
    selectable_column
    column :id
    column :first_name
    column :last_name
    column 'Pos' do |player|
      player.playing_position
    end
    column :pl_player_code
    column :pl_element_id
    column :available
    column 'Deadline' do |player|
      player.game_week_deadline_at
    end
    column 'Opp' do |player|
      player.active_game_week_opponent
    end
    column 'H/A' do |player|
      player.opponent_location_short
    end
    column 'Value' do |player|
      player.player_value
    end
    actions
  end
end
