namespace :games do
  task :play_games => :environment do
    Game.all.each do |game|
      game.calculate_score
    end
  end

  task :create_player_lineups => :environment do
    this_season = Season.current
    this_season_game_weeks = GameWeek.where(season: this_season).order(:starts_at)
    this_season_game_weeks.each do |game_week|
      if game_week.finished && !game_week.financials_processed?
        puts "Processing financials for game_week ID #{game_week.id}"
        game_week.do_financials
      end
      if game_week.starts_at < Time.now && !game_week.finished
        puts "GameWeek #{game_week.game_week_number} started & not finished"
        Player.all.each do |player|
          if player.player_game_weeks.where(game_week: game_week).count == 0 && player.game_week_deadline_at && player.game_week_deadline_at + 10.minutes < Time.now
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
