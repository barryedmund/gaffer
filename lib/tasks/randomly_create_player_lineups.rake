task :randomly_create_player_lineups => :environment do
  games = Game.joins(game_round: :league_season).where('league_seasons.league_id = ?', 2)
  games.each do |game|
    game_week = game.game_week
    create_lineups(game.home_team, game_week)
    create_lineups(game.away_team, game_week)
    puts game_week.game_week_number
  end
end

def create_lineups(team, game_week)
  team_goalies = team.team_players.joins(:player).where('players.playing_position = ?', 'Goalkeeper')
  team_goalie = team_goalies[rand(0..(team_goalies.length - 1))]
  team_goalie_player_game_week = team_goalie.player.player_game_weeks.joins(:game_week).where('player_game_weeks.game_week_id = ?', game_week.id).first
  unless team_goalie_player_game_week
    team_goalie_player_game_week = PlayerGameWeek.create(player: team_goalie.player, game_week: game_week, minutes_played: 0, goals: 0, clean_sheet: true)
  end
  team_goalie_squad_position = SquadPosition.find_by(long_name: team_goalie.player.playing_position)
  goalie_player_lineup = PlayerLineup.create(team: team, player_game_week: team_goalie_player_game_week, squad_position: team_goalie_squad_position)

  team_outfields = team.team_players.joins(:player).where.not('players.playing_position = ?', 'Goalkeeper')
  while PlayerLineup.joins(player_game_week: :game_week).where("player_lineups.team_id = ? AND game_weeks.game_week_number = ?", team.id, game_week.game_week_number).length < 11 do
    team_outfield = team_outfields[rand(0..(team_outfields.length - 1))]
    team_outfield_player_game_week = team_outfield.player.player_game_weeks.joins(:game_week).where('player_game_weeks.game_week_id = ?', game_week.id).first
    unless team_outfield_player_game_week
      team_outfield_player_game_week = PlayerGameWeek.create(player: team_outfield.player, game_week: game_week, minutes_played: 0, goals: 0, clean_sheet: true)
    end
    team_outfield_squad_position = SquadPosition.find_by(long_name: team_outfield.player.playing_position)
    outfield_player_lineup = PlayerLineup.create(team: team, player_game_week: team_outfield_player_game_week, squad_position: team_outfield_squad_position)
  end
end
