namespace :games do
  task :play_games => :environment do
    Game.all.each do |game|
      game.calculate_score
      game.credit_gate_receipts
      game.debit_weekly_salaries
    end
  end

  task :create_player_lineups => :environment do
    this_season = Season.current
    this_season_game_weeks = GameWeek.where(season: this_season).order(:starts_at)
    this_season_game_weeks.each do |game_week|
      if game_week.starts_at < Time.now && !game_week.finished && game_week.player_game_weeks.count == 0
        Player.all.each do |player|
          player_game_week = PlayerGameWeek.create(player: player, game_week: game_week, minutes_played: 0, goals: 0, clean_sheet: true)

          league_seasons = LeagueSeason.where(season: this_season)
          league_seasons.each do |league_season|
            league = league_season.league
            team_player = TeamPlayer.joins(team: :league).where('team_players.player_id = ? AND leagues.id = ?', player.id, league.id).first
            if team_player
              team = team_player.team
              player_lineup = PlayerLineup.new(team: team, player_game_week: player_game_week, squad_position: team_player.squad_position)
              if player_lineup.save
                puts "#{player.full_name}_____ #{team.title} ____ #{team_player.squad_position.inspect}"
                puts "Yep ***********"
              else
                puts "Nope _______"
              end
            end
          end

        end
        # league_seasons = LeagueSeason.where(season: this_season)
        # league_seasons.each do |league_season|
        #   league = league_season.league
        #   teams = league.teams
        # end
      end
    end
  end
end
