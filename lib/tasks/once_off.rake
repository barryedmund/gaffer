namespace :once_off do
  task :back_fill_player_values => :environment do
    Player.all.each do |player|
      GameWeek.where(finished: true).order(:id).each do |game_week|
        if this_player_game_week = PlayerGameWeek.where(game_week: game_week, player: player).first
          player_game_week_so_far = player.player_game_weeks.joins(:game_week).where('game_weeks.id < ?', game_week.id)

          # total_minutes_played
          total_minutes_played = player_game_week_so_far.sum(:minutes_played)

          # total_defensive_contribution
          total_clean_sheet_minutes = 0
          player_game_week_so_far.each do |player_game_week|
            clean_sheet_minutes = player_game_week.minutes_played > 0 ? (player_game_week.minutes_played.to_f / (player_game_week.goals_conceded + 1)) : 0.0
            if player.playing_position === 'Midfielder'
              clean_sheet_minutes = clean_sheet_minutes / 2
            elsif player.playing_position === 'Forward'
              clean_sheet_minutes = 0.0
            end
            total_clean_sheet_minutes += clean_sheet_minutes
          end
          total_defensive_contribution = total_clean_sheet_minutes.round(1)

          # total_defensive_contribution_per_90
          total_defensive_contribution_per_90 = total_minutes_played > 0 ? (total_defensive_contribution / (total_minutes_played.to_f / 90)).round(3) : (0.to_f).round(3)

          # percentage_of_minutes_played
          percentage_of_minutes_played = player_game_week_so_far.count > 0 ? (total_minutes_played.to_f / (player_game_week_so_far.count * 90).to_f).round(3) : 0

          # defensive_index
          defensive_index = ((total_defensive_contribution_per_90 / 90) * percentage_of_minutes_played) / 4

          # total_attacking_contribution
          attacking_contribution = 0
          if player.playing_position === 'Goalkeeper'
            attacking_contribution += (player_game_week_so_far.sum(:goals) + (player_game_week_so_far.sum(:assists).to_f * 0.5))
          elsif player.playing_position === 'Defender'
            attacking_contribution += (player_game_week_so_far.sum(:goals) + (player_game_week_so_far.sum(:assists).to_f * 0.4))
          elsif player.playing_position === 'Midfielder'
            attacking_contribution += (player_game_week_so_far.sum(:goals) + (player_game_week_so_far.sum(:assists).to_f * 0.3))
          elsif player.playing_position === 'Forward'
            attacking_contribution += (player_game_week_so_far.sum(:goals) + (player_game_week_so_far.sum(:assists).to_f * 0.2))
          end
          total_attacking_contribution = attacking_contribution.round(1)

          # total_attacking_contribution_per_90
          total_attacking_contribution_per_90 = total_minutes_played > 0 ? (total_attacking_contribution / (total_minutes_played.to_f / 90)).round(3) : (0.to_f).round(3)

          # attacking_index
          attacking_index = ((total_attacking_contribution_per_90) * percentage_of_minutes_played)

          # player_value
          value = ((defensive_index + attacking_index) * 10000000) * 1.5
          rounded_value = [value, Rails.application.config.minimum_player_value].max.round

          puts "#{player.full_name} (#{game_week.game_week_number}): #{rounded_value}"
          this_player_game_week.update_attributes(player_value: rounded_value)
        end
      end
    end
  end
end
