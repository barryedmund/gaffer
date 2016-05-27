task :get_player_game_week_stats => :environment do
  continue = true
  i = 1
  while continue
    response = Net::HTTP.get_response(URI("http://fantasy.premierleague.com/web/api/elements/#{i}/"))
    break if response.code.to_i != 200
    body = JSON.parse(response.body)
    player = Player.find_by(pl_player_code: body['code'])
    season = player.competition.current_season
    number_of_games = body['fixture_history']['all'].length
    previous_game_game_week_number = 0
    games_per_game_week = 0
    puts "#{body['first_name']} #{body['second_name']}"
    for j in 0..(number_of_games - 1)
      current_game_game_week_number = body['fixture_history']['all'][j][1]
      game_week = season.game_weeks.find_by(game_week_number: current_game_game_week_number)

      if current_game_game_week_number != previous_game_game_week_number
        games_per_game_week = 1
        total_minutes_played = body['fixture_history']['all'][j][3]
        total_goals_scored = body['fixture_history']['all'][j][4]
        total_goals_conceded = body['fixture_history']['all'][j][7]
      else
        games_per_game_week += 1
        total_minutes_played += body['fixture_history']['all'][j][3]
        total_goals_scored += body['fixture_history']['all'][j][4]
        total_goals_conceded += body['fixture_history']['all'][j][7]
      end
      if ((j + 1) === number_of_games) || (body['fixture_history']['all'][j + 1][1] != current_game_game_week_number)
        puts "> #{current_game_game_week_number}"
        average_minutes_played = total_minutes_played / games_per_game_week
        average_goals_scored = total_goals_scored / games_per_game_week
        clean_sheet = (total_goals_conceded == 0) ? true : false
        PlayerGameWeek.create(player_id: player.id, game_week_id: game_week.id, minutes_played: average_minutes_played, goals: average_goals_scored, clean_sheet: clean_sheet)
      end
      previous_game_game_week_number = current_game_game_week_number
    end
    i += 1
  end
end
