namespace :games do
  task :play_games => :environment do
    start = Time.now
    Game.where(is_complete: false).each do |game|
      game.calculate_score
    end
    puts "End: #{Time.now - start}"
  end

  task :create_player_lineups => :environment do
    this_season = Season.current
    this_season_game_weeks = GameWeek.where(season: this_season).order(:starts_at)
    this_season_game_weeks.each do |game_week|
      if game_week.finished && !game_week.financials_processed?
        puts "Processing financials for game_week ID #{game_week.id}"
        game_week.do_financials
        Team.all.each do |team|
          if team.cash_balance_cents < 0
            team.auto_transfer_list_squad
          else
            team.delist_non_self_listed_team_players if team.should_be_back_in_the_black
          end
        end
        # Add player's financial value to the most recent player_game_week
        Player.all.each do |player|
          puts "> Updating #{player.full_name}'s value for this game_week."
          player_game_week = PlayerGameWeek.where(player: player, game_week: game_week).first
          if player_game_week
            player_game_week.update_attributes(player_value: player.calculate_player_value)
          end
        end
      end
      if game_week.starts_at < Time.now && !game_week.finished
        puts "GameWeek #{game_week.game_week_number} started & not finished"
        Player.all.each do |player|
          if player.player_game_weeks.where(game_week: game_week).count == 0 && player.game_week_deadline_at && player.game_week_deadline_at < Time.now
            player_game_week = PlayerGameWeek.create(player: player, game_week: game_week, minutes_played: 0, goals: 0, clean_sheet: true, goals_conceded: 0)
            puts "Created PlayerGameWeek ##{game_week.game_week_number} for #{player.first_name} #{player.last_name}"
            league_seasons = LeagueSeason.where(season: this_season)
            league_seasons.each do |league_season|
              league = league_season.league
              team_player = TeamPlayer.joins(team: :league).where('team_players.player_id = ? AND leagues.id = ?', player.id, league.id).first
              if team_player
                team = team_player.team
                PlayerLineup.create(team: team, player_game_week: player_game_week, squad_position: team_player.squad_position)
              end
            end
          end
        end
      end
    end
  end
end
