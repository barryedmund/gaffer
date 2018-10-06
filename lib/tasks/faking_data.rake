namespace :faking_data do
	task :randomly_assign_team_players, [:league_id] => :environment do |task, args|
		puts "Rake task: randomly_assign_team_players"
	  teams = Team.where(league_id: args.league_id)
	  valuable_players = Player.joins(:player_game_weeks).having('SUM(player_game_weeks.minutes_played) > 2000').group('players.id').order('SUM(player_game_weeks.goals)')
	  valuable_players.each do |vp|
	    team = teams[rand(0..(teams.length - 1))]
	    team_player = TeamPlayer.create(team: team, player: vp, squad_position: SquadPosition.find_by(short_name: 'SUB'), first_team: false)
	    team_player_contract = Contract.create(team: team, team_player: team_player, weekly_salary_cents: rand(500000..10000000), player: team_player.player, starts_at: Date.today, ends_at: 1.year.from_now)
	  end
	end

	task :randomly_create_player_lineups => :environment do
		puts "Rake task: randomly_create_player_lineups"
	  games = Game.joins(game_round: :league_season).where('league_seasons.league_id = ?', 2)
	  games.each do |game|
	    game_week = game.game_week
	    create_lineups(game.home_team, game_week)
	    create_lineups(game.away_team, game_week)
	  end
	end

	def create_lineups(team, game_week)
	  all_unassigned_team_players = team.team_players

	  #
	  # Get the goalie
	  #
	  team_goalies = team.team_players.joins(:player).where('players.playing_position = ?', 'Goalkeeper')
	  team_goalie = team_goalies[rand(0..(team_goalies.length - 1))]
	  team_goalie_player_game_week = team_goalie.player.player_game_weeks.joins(:game_week).where('player_game_weeks.game_week_id = ?', game_week.id).first
	  unless team_goalie_player_game_week
	    team_goalie_player_game_week = PlayerGameWeek.create(player: team_goalie.player, game_week: game_week, minutes_played: 0, goals: 0, clean_sheet: true)
	  end
	  team_goalie_squad_position = SquadPosition.find_by(long_name: team_goalie.player.playing_position)
	  goalie_player_lineup = PlayerLineup.create(team: team, player_game_week: team_goalie_player_game_week, squad_position: team_goalie_squad_position)
	  all_unassigned_team_players = all_unassigned_team_players.where.not(id: team_goalie.id)

	  #
	  # Get the outfield players
	  #
	  team_outfields = team.team_players.joins(:player).where.not('players.playing_position = ?', 'Goalkeeper')
	  while PlayerLineup.joins(player_game_week: :game_week).where("player_lineups.team_id = ? AND game_weeks.game_week_number = ?", team.id, game_week.game_week_number).length < 11 do
	    team_outfield = team_outfields[rand(0..(team_outfields.length - 1))]
	    team_outfield_player_game_week = team_outfield.player.player_game_weeks.joins(:game_week).where('player_game_weeks.game_week_id = ?', game_week.id).first
	    unless team_outfield_player_game_week
	      team_outfield_player_game_week = PlayerGameWeek.create(player: team_outfield.player, game_week: game_week, minutes_played: 0, goals: 0, clean_sheet: true)
	    end
	    team_outfield_squad_position = SquadPosition.find_by(long_name: team_outfield.player.playing_position)
	    outfield_player_lineup = PlayerLineup.create(team: team, player_game_week: team_outfield_player_game_week, squad_position: team_outfield_squad_position)
	    all_unassigned_team_players = all_unassigned_team_players.where.not(id: team_outfield.id)
	  end

	  #
	  # Get the subs
	  #
	  team_sub_squad_position = SquadPosition.find_by(short_name: 'SUB')
	  all_unassigned_team_players.each do |unassigned_team_player|
	    team_sub_player_game_week = unassigned_team_player.player.player_game_weeks.joins(:game_week).where('player_game_weeks.game_week_id = ?', game_week.id).first
	    unless team_sub_player_game_week
	      team_sub_player_game_week = PlayerGameWeek.create(player: unassigned_team_player.player, game_week: game_week, minutes_played: 0, goals: 0, clean_sheet: true)
	    end
	    sub_player_lineup = PlayerLineup.create(team: team, player_game_week: team_sub_player_game_week, squad_position: team_sub_squad_position)
	  end
	end
end
