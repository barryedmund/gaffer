task :randomly_assign_team_players => :environment do
  teams = Team.where(league_id: 2)
  valuable_players = Player.joins(:player_game_weeks).having('SUM(player_game_weeks.minutes_played) > 2500').group('players.id').order('SUM(player_game_weeks.minutes_played)')
  valuable_players.each do |vp|
    team = teams[rand(0..3)]
    TeamPlayer.create(team: team, player: vp, squad_position: SquadPosition.find_by(short_name: 'SUB'), first_team: false)
  end
end
