task :randomly_assign_team_players => :environment do
  teams = Team.where(league_id: 2)
  valuable_players = Player.joins(:player_game_weeks).having('SUM(player_game_weeks.minutes_played) > 2000').group('players.id').order('SUM(player_game_weeks.goals)')
  valuable_players.each do |vp|
    team = teams[rand(0..3)]
    team_player = TeamPlayer.create(team: team, player: vp, squad_position: SquadPosition.find_by(short_name: 'SUB'), first_team: false)
    team_player_contract = Contract.create(team: team, team_player: team_player, weekly_salary_cents: rand(500000..10000000), player: team_player.player, starts_at: Date.today, ends_at: 1.year.from_now)
  end
end
