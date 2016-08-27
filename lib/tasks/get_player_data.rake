namespace :player_data do
  task :get_players => :environment do
    response = Net::HTTP.get_response(URI("https://fantasy.premierleague.com/drf/bootstrap-static"))
    if response.code.to_i == 200
      body = JSON.parse(response.body)
      playing_position_elements = body['element_types']
      real_team_elements = body['teams']
      number_of_players = body['elements'].length
      for i in 0..(number_of_players - 1)
        current_player = body['elements'][i]
        
        player_element_id = current_player['id']
        player_code = current_player['code']
        player_first_name = current_player['first_name']
        player_last_name = current_player['second_name']
        player_position = playing_position_elements.find { |e| e['id'] == current_player['element_type']}['singular_name']
        player_real_team = real_team_elements.find { |f| f['code'] == current_player['team_code']}['short_name']
        player_competition = Competition.find_by description: 'Premier League'

        player = Player.find_by(pl_player_code: player_code)
        if player
          player.update_attributes(pl_element_id: player_element_id, real_team_short_name: player_real_team)
        else
          player = Player.create(first_name: player_first_name, last_name: player_last_name, playing_position: player_position, pl_player_code: player_code, competition: player_competition, pl_element_id: player_element_id, real_team_short_name: player_real_team)
          League.all.each do |league|
            NewsItem.create(league: league, news_item_resource_type: 'Player', news_item_resource_id: player.id, body: "New free agent")
          end
        end
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
    i = 1
    continue = true
    while continue
      response = Net::HTTP.get_response(URI("https://fantasy.premierleague.com/drf/element-summary/#{i}"))
      break unless response.code.to_i == 200
      body = JSON.parse(response.body)
      body_game_weeks = body['history']
      body_history = body['history_past']

      # If the player has played in the EPL in a previous season
      if body_history.length > 0
        player_code = body_history[body_history.length - 1]['element_code']
        player = Player.find_by(pl_player_code: player_code)
      else
        player = Player.find_by(pl_element_id: i)
      end

      # If the player was found
      if player
        season = player.competition.current_season
        player_game_weeks = player.player_game_weeks.joins(:game_week).where("game_weeks.season_id =?", season.id).order('game_weeks.game_week_number DESC')  
        current_game_week = season.get_current_game_week
        
        total_minutes_played = 0
        total_goals_scored = 0
        total_goals_conceded = 0
        total_assists = 0
        total_clean_sheet = true
        fixtures_in_game_week = 0;
        
        # Go through each 'round' and, if it is this round, update the counter
        for j in 0..(body_game_weeks.length - 1)
          if body_game_weeks[j]['round'] == current_game_week.game_week_number
            fixtures_in_game_week = fixtures_in_game_week + 1
            total_minutes_played += body_game_weeks[j]['minutes']
            total_goals_scored += body_game_weeks[j]['goals_scored']
            total_goals_conceded += body_game_weeks[j]['goals_conceded']
            total_assists += body_game_weeks[j]['assists']
          end
        end
        
        #  If he played and didn't concede goals
        if !(total_minutes_played > 0 && total_goals_conceded == 0)
          total_clean_sheet = false
        end

        # If it was a multi-fixture EPL round for this player
        if fixtures_in_game_week > 1
          total_minutes_played = total_minutes_played / fixtures_in_game_week
          total_goals_scored = total_goals_scored / fixtures_in_game_week
          total_goals_conceded = total_goals_conceded / fixtures_in_game_week
          total_assists = total_assists / fixtures_in_game_week
        end

        this_player_current_player_game_week = PlayerGameWeek.where('game_week_id = ? AND player_id = ?', current_game_week.id, player.id).first

        # If the PlayerGameWeek was found
        if this_player_current_player_game_week
          this_player_current_player_game_week.update_attributes(minutes_played: total_minutes_played, goals: total_goals_scored, clean_sheet: total_clean_sheet, goals_conceded: total_goals_conceded, assists: total_assists)
          puts "#{player.full_name}: #{this_player_current_player_game_week.inspect}"
        end
      else

      end
      i = i + 1
    end
  end
end
