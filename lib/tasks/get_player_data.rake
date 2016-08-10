namespace :player_data do
  task :get_players => :environment do
    response = Net::HTTP.get_response(URI("https://fantasy.premierleague.com/drf/bootstrap-static"))
    if response.code.to_i == 200
      body = JSON.parse(response.body)
      playing_position_elements = body['element_types']
      number_of_players = body['elements'].length
      for i in 0..(number_of_players - 1)
        current_player = body['elements'][i]
        
        player_code = current_player['code']
        player_first_name = current_player['first_name']
        player_last_name = current_player['second_name']
        player_position = playing_position_elements.find { |e| e['id'] == current_player['element_type']}['singular_name']
        player_competition = Competition.find_by description: 'Premier League'

        player = Player.find_by(pl_player_code: player_code) ? Player.find_by(pl_player_code: player_code) : Player.create(first_name: player_first_name, last_name: player_last_name, playing_position: player_position, pl_player_code: player_code, competition: player_competition)

        puts player.inspect
      end
    end
  end

  task :get_game_week_details => :environment do
    response = Net::HTTP.get_response(URI("https://fantasy.premierleague.com/drf/bootstrap-static"))
    if response.code.to_i == 200
      body = JSON.parse(response.body)
      game_week_elements = body['events']
      current_season = Season.current.first
      for i in 0..(game_week_elements.length - 1)
        current_element = game_week_elements[i]
        start_time = Time.at(current_element['deadline_time_epoch']).utc
        if GameWeek.find_by(game_week_number: current_element['id'])
          game_week = GameWeek.find_by(game_week_number: current_element['id'])
          game_week.update_attributes(starts_at: start_time.to_datetime, finished: current_element['finished'])
        else
          game_week = GameWeek.create(game_week_number: current_element['id'], starts_at: start_time.to_datetime, ends_at: start_time + 1.second, finished: current_element['finished'], season: current_season)
        end
        puts game_week.inspect
      end
    end
  end

  task :get_player_game_weeks => :environment do
    Player.all.each do |player|
      season = player.competition.current_season
      player_game_weeks = player.player_game_weeks.joins(:game_week).where(
        "game_weeks.season_id =?", season.id).order('game_weeks.game_week_number DESC')
      puts season.inspect
    end 
  end
end
  # continue = true
  # i = 1
  # while continue
  #   response = Net::HTTP.get_response(URI("http://fantasy.premierleague.com/web/api/elements/#{i}/"))
  #   break unless response.code.to_i == 200
  #   body = JSON.parse(response.body)

  #   player_code = body['code']
  #   player_first_name = body['first_name']
  #   player_last_name = body['second_name']
  #   player_position = body['type_name']
  #   player_competition = Competition.find_by description: 'Premier League'

  #   player = Player.find_by(pl_player_code: player_code) ? Player.find_by(pl_player_code: player_code) : Player.create(first_name: player_first_name, last_name: player_last_name, playing_position: player_position, pl_player_code: player_code, competition: player_competition)

  #   puts player.inspect
    
  #   season = player.competition.current_season
  #   player_game_weeks = player.player_game_weeks.joins(:game_week).where("game_weeks.season_id =?", season.id).order('game_weeks.game_week_number DESC')
  #   number_of_games = body['fixture_history']['all'].length
  #   previous_game_game_week_number = 0
  #   games_per_game_week = 0
  #   for j in 0..(number_of_games - 1)
  #     current_game_game_week_number = body['fixture_history']['all'][j][1]
  #     game_week = season.game_weeks.find_by(game_week_number: current_game_game_week_number)
  #     if current_game_game_week_number != previous_game_game_week_number
  #       games_per_game_week = 1
  #       total_minutes_played = body['fixture_history']['all'][j][3]
  #       total_goals_scored = body['fixture_history']['all'][j][4]
  #       total_goals_conceded = body['fixture_history']['all'][j][7]
  #     else
  #       games_per_game_week += 1
  #       total_minutes_played += body['fixture_history']['all'][j][3]
  #       total_goals_scored += body['fixture_history']['all'][j][4]
  #       total_goals_conceded += body['fixture_history']['all'][j][7]
  #     end
  #     if ((j + 1) === number_of_games) || (body['fixture_history']['all'][j + 1][1] != current_game_game_week_number)
  #       average_minutes_played = total_minutes_played / games_per_game_week
  #       average_goals_scored = total_goals_scored / games_per_game_week
  #       clean_sheet = (total_goals_conceded == 0) ? true : false
  #       # If this task is run after just one game of a two-game game week has been played, this bit makes sure that the pgw is updated rather than skipped.
  #       if (games_per_game_week > 1) && player_game_weeks.length > 0 && (player_game_weeks.first.game_week.game_week_number === game_week.game_week_number)
  #         player_game_weeks.first.update(minutes_played: average_minutes_played, goals: average_goals_scored, clean_sheet: clean_sheet)
  #       end
  #       PlayerGameWeek.create(player_id: player.id, game_week_id: game_week.id, minutes_played: average_minutes_played, goals: average_goals_scored, clean_sheet: clean_sheet)
  #     end
  #     previous_game_game_week_number = current_game_game_week_number
  #   end

  #   number_of_seasons = body['season_history'].length
  #   most_recent_season = body['season_history'][number_of_seasons - 1][0]
  #   most_recent_season.gsub!("/","_")
  #   File.open("public/player_data/#{most_recent_season}_#{player_code}.json","w") do |f|
  #     f.write(body.to_json)
  #   end 

  #   i += 1
  # end

