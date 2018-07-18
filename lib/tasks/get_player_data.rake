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
        player_status = current_player['status']
        player_position = playing_position_elements.find { |e| e['id'] == current_player['element_type']}['singular_name']
        player_real_team = real_team_elements.find { |f| f['code'] == current_player['team_code']}['short_name']
        player_news = process_news(current_player['news'])
        player_competition = Competition.find_by description: 'Premier League'

        player = Player.find_by(pl_player_code: player_code)
        if player
          if player_status == "u"
            player.update_attributes(pl_element_id: player_element_id, real_team_short_name: player_real_team, available: false, news: player_news)
            TeamPlayer.where(player: player).destroy_all
          else
            player.update_attributes(pl_element_id: player_element_id, real_team_short_name: player_real_team, available: true, news: player_news)
          end
        else
          if player_status != "u"
            player = Player.create(first_name: player_first_name, last_name: player_last_name, playing_position: player_position, pl_player_code: player_code, competition: player_competition, pl_element_id: player_element_id, real_team_short_name: player_real_team, available: true, news: player_news)
            League.all.each do |league|
              NewsItem.create(league: league, news_item_resource_type: 'Player', news_item_type: 'new_free_agent', news_item_resource_id: player.id, body: "New free agent")
            end
          end
        end
      end
    end
  end

  task :get_game_week_details => :environment do
    response = Net::HTTP.get_response(URI("https://fantasy.premierleague.com/drf/bootstrap-static"))
    if response.code.to_i == 200
      body = JSON.parse(response.body)
      game_week_elements = body['events']
      current_season = Season.current.first
      if current_season && !current_season.is_completed
        for i in 0..(game_week_elements.length - 1)
          current_element = game_week_elements[i]
          start_time = Time.at(current_element['deadline_time_epoch']).utc

          if GameWeek.where(game_week_number: current_element['id'], season: current_season).first
            game_week = GameWeek.where(game_week_number: current_element['id'], season: current_season).first
            game_week.update_attributes(starts_at: start_time.to_datetime, ends_at: start_time + 1.second, finished: current_element['finished'])
          else
            game_week = GameWeek.create(game_week_number: current_element['id'], starts_at: start_time.to_datetime, ends_at: start_time + 1.second, finished: current_element['finished'], season: current_season)
          end
          puts game_week.inspect
        end
      end
    end
  end

  task :get_player_game_weeks => :environment do
    active_game_week = Competition.find_by(description: 'Premier League').current_season.get_current_game_week
    if active_game_week && active_game_week.starts_at <= Time.now
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
          player = Player.where(pl_element_id: i, available: true).first
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
          fixtures_in_game_week = 0

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
            puts "DGW: #{player.first_name} #{player.last_name}"
            total_minutes_played = total_minutes_played / fixtures_in_game_week
            total_goals_scored = total_goals_scored.to_f / fixtures_in_game_week
            total_goals_conceded = total_goals_conceded.to_f / fixtures_in_game_week
            total_assists = total_assists.to_f / fixtures_in_game_week
          end

          this_player_current_player_game_week = PlayerGameWeek.where('game_week_id = ? AND player_id = ?', current_game_week.id, player.id).first

          # If the PlayerGameWeek was found
          if this_player_current_player_game_week
            this_player_current_player_game_week.update_attributes(minutes_played: total_minutes_played, goals: total_goals_scored, clean_sheet: total_clean_sheet, goals_conceded: total_goals_conceded, assists: total_assists)
          end
        end
        i = i + 1
      end
    end
  end

  task :get_player_gameweek_deadlines => :environment do
    if Time.now.hour % 2 == 0
      active_game_week = Competition.find_by(description: 'Premier League').current_season.get_current_game_week
      active_game_week_number = active_game_week.game_week_number
      i = 1
      continue = true
      while continue
        response = Net::HTTP.get_response(URI("https://fantasy.premierleague.com/drf/element-summary/#{i}"))
        break unless response.code.to_i == 200

        body = JSON.parse(response.body)
        body_history = body['history_past']
        body_history_full = body['history']
        body_fixture_summary = body['fixtures_summary']

        if body_history.length > 0
          player_code = body_history[body_history.length - 1]['element_code']
          player = Player.where(pl_player_code: player_code, available: true).first
        else
          player = Player.where(pl_element_id: i, available: true).first
        end

        if player && (body_fixture_summary.length > 0) && (body_fixture_summary[0]['event'] == active_game_week_number)
          body_history_game_week_element = 0
          fixtures_in_game_week = 0
          # Go through each 'round' and, if it is this round, update the counter
          for j in 0..(body_history_full.length - 1)
            if body_history_full[j]['round'] == active_game_week_number
              fixtures_in_game_week = fixtures_in_game_week + 1
              body_history_game_week_element = j
            end
          end

          if fixtures_in_game_week > 1
            deadline_datetime = DateTime.parse(body_history_full[body_history_game_week_element - (fixtures_in_game_week - 1)]['kickoff_time'])
          else
            deadline_datetime = DateTime.parse(body_fixture_summary[0]['kickoff_time'])
          end
          active_game_week_opponent = body_fixture_summary[0]['opponent_short_name']
          active_game_week_location = body_fixture_summary[0]['is_home'] == true ? 'home' : 'away'

          if player.player_game_weeks.where(game_week: active_game_week).count == 0
            player.update_attributes(
            game_week_deadline_at: deadline_datetime,
            active_game_week_opponent: active_game_week_opponent,
            active_game_week_location: active_game_week_location)
            puts "#{player.full_name}: #{player.game_week_deadline_at}"
          else
            player.update_attributes(
            active_game_week_opponent: active_game_week_opponent,
            active_game_week_location: active_game_week_location)
            puts ">>>> #{player.full_name}: #{player.game_week_deadline_at}"
          end
        end
        i = i + 1
      end
    end
  end

  task :cleanse_departed_players => :environment do
    response = Net::HTTP.get_response(URI("https://fantasy.premierleague.com/drf/bootstrap-static"))
    if response.code.to_i == 200
      body = JSON.parse(response.body)
      Player.all.each do |player|
        if !body['elements'].find { |epl_player| epl_player['code'] == player.pl_player_code}
          puts "#{player.full_name} has departed."
          player.update_attributes(available: false)
          TeamPlayer.where(player: player).destroy_all
        end
      end
    end
  end

  def process_news(news)
    if(news != "")
      news.gsub!(/Expected back/, 'Returns')
      news.gsub!(/Lack of match fitness/i, 'Not fit')
      news.gsub!(/Anterior cruciate ligament/i, 'Inj')
      news.gsub!(/.+?(?=injury)(injury)/i, 'Inj')
      news.gsub!(/chance of playing/i, 'fit')
      news.gsub!(/Unknown return date/i, 'No return date')
      news.gsub!(/Dislocation/i, 'inj')
      news = "Not available" if news.match(/Unavailable to face parent club/).present?
      news = "Not available" if news.match(/that he would not be available for selection/).present?
      news = "Out on loan" if news.match(/Joined/).present? && news.match(/loan/).present?
    end
    news
  end
end
