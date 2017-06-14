namespace :wrap_up_season do
  task :distribute_end_of_season_cash => :environment do
    LeagueSeason.all.each do |league_season|
      
      if league_season.is_ready_to_be_wrapped_up
        league_standings = league_season.league.get_standings
        puts "--#{league_season.league.name}--"
        league_standings.each_with_index do |standings_row, index|

          team = standings_row[:team_record]

          number_of_teams = league_standings.length
          end_of_season_reward = (number_of_teams - index) * Rails.application.config.reward_per_position_at_end_of_season

          team.add_cash(end_of_season_reward)
          finishing_position = (index + 1) === 1 ? "Champions" : ((index + 1) === number_of_teams ? "Wooden spoon" : "#{(index + 1).ordinalize} place")

          puts "#{team.title}: #{finishing_position}"
          NewsItem.create(league: league_season.league,
                          news_item_resource_type: 'Team',
                          news_item_type: 'end_of_season_reward',
                          news_item_resource_id: team.id,
                          body: "#{finishing_position}: #{team.title}",
                          content: end_of_season_reward)
          team.delist_involuntarily_listed_team_players if team.should_be_back_in_the_black
        end
        league_season.update_attributes(is_completed: true)
      end
    end
  end


  # Run once unless new achievements have been created in which case just replace the array contents with the new awards
  task :create_achievements => :environment do
    [:most_valuable_goalkeeper,
    :best_defensive_contribution_goalkeeper,
    :best_attacking_contribution_goalkeeper,
    :highest_paid_goalkeeper,
    :worst_signing_goalkeeper,
    :best_signing_goalkeeper,

    :most_valuable_defender,
    :best_defensive_contribution_defender,
    :best_attacking_contribution_defender,
    :highest_paid_defender,
    :worst_signing_defender,
    :best_signing_defender,

    :most_valuable_midfielder,
    :best_defensive_contribution_midfielder,
    :best_attacking_contribution_midfielder,
    :highest_paid_midfielder,
    :worst_signing_midfielder,
    :best_signing_midfielder,

    :most_valuable_forward,
    :best_defensive_contribution_forward,
    :best_attacking_contribution_forward,
    :highest_paid_forward,
    :worst_signing_forward,
    :best_signing_forward,

    :most_valuable_overall,
    :best_defensive_contribution_overall,
    :best_attacking_contribution_overall,
    :highest_paid_overall,
    :worst_signing_overall,
    :best_signing_overall,

    :richect_team,
    :poorest_team,
    :highest_total_weekly_salary_team,
    :lowest_total_weekly_salary_team,
    :highest_average_weekly_salary_team,
    :lowest_average_weekly_salary_team,
    :most_valuable_team,
    :least_valuable_team,
    :highest_average_value_of_players_team,
    :lowest_average_value_of_players_team,
    :biggest_squad,
    :smallest_squad].each do |award|
      new_achievement = Achievement.create(award_type: award, name: award.to_s.titleize)
      puts new_achievement.inspect
    end
  end

  task :team_players_records => :environment do
    current_season = Season.current.first
    League.all.each do |league|
      league_teams = league.teams
      league_players = Player.where(available: true).where(id: (Player.joins(team_players: [:team => :league]).where('leagues.id = ?', league.id) ).map(&:id))
      unattached_players = Player.get_all_unattached_players(league)
      league_teams_team_players = league_teams.joins(:team_players)
      league_team_players = TeamPlayer.joins(:team).where('teams.league_id = ?', league.id)

      puts ""
      puts "_______ #{league.name} _______"

      # Player awards

      ['Goalkeeper', 'Defender', 'Midfielder', 'Forward'].each do |position|
        puts "____ #{position} awards ____"
        league_players_at_position = league_players.where(playing_position: position)
        league_team_players_at_position = league_team_players.joins(:player).where('players.playing_position = ?', position)
        unattached_players_at_position = unattached_players.where(playing_position: position)
        
        most_valuable_at_position = league_players_at_position.sort_by{ |player| player.player_value(current_season) }.last
        most_valuable_at_position_team = league_teams_team_players.where('team_players.player_id = ?', most_valuable_at_position.id).first
        puts "Most valuable is #{most_valuable_at_position.full_name} worth #{most_valuable_at_position.player_value(current_season)} owned by #{most_valuable_at_position_team.title}."

        total_defensive_contribution_at_position = league_players_at_position.sort_by{ |player| player.total_defensive_contribution(current_season) }.last
        total_defensive_contribution_at_position_team = league_teams_team_players.where('team_players.player_id = ?', total_defensive_contribution_at_position.id).first
        puts "Highest defensive contribution is #{total_defensive_contribution_at_position.full_name} with #{total_defensive_contribution_at_position.total_defensive_contribution(current_season)} owned by #{total_defensive_contribution_at_position_team.title}."

        total_attacking_contribution_at_position = league_players_at_position.sort_by{ |player| player.total_attacking_contribution(current_season) }.last
        total_attacking_contribution_at_position_team = league_teams_team_players.where('team_players.player_id = ?', total_attacking_contribution_at_position.id).first
        puts "Highest attacking contribution is #{total_attacking_contribution_at_position.full_name} with #{total_attacking_contribution_at_position.total_attacking_contribution(current_season)} owned by #{total_attacking_contribution_at_position_team.title}."

        highest_paid_team_player = league_team_players_at_position.sort_by{ |team_player| team_player.current_contract.weekly_salary_cents }.last
        puts "Highest paid is #{highest_paid_team_player.full_name} earning #{highest_paid_team_player.current_contract.weekly_salary_cents} owned by #{highest_paid_team_player.team.title}."

        team_player_values = league_team_players_at_position.sort_by{ |team_player| team_player.relative_value }
        overrated_team_player = team_player_values.first
        puts "Worst signing is #{overrated_team_player.full_name} (value: #{overrated_team_player.player.player_value(current_season)}, salary: #{overrated_team_player.current_contract.weekly_salary_cents}) owned by #{overrated_team_player.team.title}."

        underrated_team_player = team_player_values.last
        puts "Best signing is #{underrated_team_player.full_name} (value: #{underrated_team_player.player.player_value(current_season)}, salary: #{underrated_team_player.current_contract.weekly_salary_cents}) owned by #{underrated_team_player.team.title}."

        highest_value_unsigned_player = unattached_players_at_position.sort_by{ |player| player.player_value(Season.current.first) }.last
        puts "Best unsigned is #{highest_value_unsigned_player.full_name}."
      end

      # Team awards
      teams_in_order_of_cash = league_teams.order(:cash_balance_cents)
      richest_team = teams_in_order_of_cash.last
      poorest_team = teams_in_order_of_cash.first
      puts "____ Team awards ____"
      puts "Richest team is #{richest_team.title} with #{richest_team.cash_balance_cents}"
      puts "Poorest team is #{poorest_team.title} with #{poorest_team.cash_balance_cents}"
      
      teams_in_order_of_total_wage_bill = league_teams.sort_by { |team| team.total_weekly_wage_bill }
      highest_wage_bill_team = teams_in_order_of_total_wage_bill.last
      lowest_wage_bill_team = teams_in_order_of_total_wage_bill.first
      puts "Highest total weekly salary is #{highest_wage_bill_team.title} of #{highest_wage_bill_team.total_weekly_wage_bill}"
      puts "Lowest total weekly salary is #{lowest_wage_bill_team.title} of #{lowest_wage_bill_team.total_weekly_wage_bill}"

      teams_in_order_of_average_weekly_salary = league_teams.sort_by { |team| team.average_weekly_wage_bill }
      highest_average_salary_team = teams_in_order_of_average_weekly_salary.last
      lowest_average_salary_team = teams_in_order_of_average_weekly_salary.first
      puts "Highest average weekly salary is #{highest_average_salary_team.title} of #{highest_average_salary_team.average_weekly_wage_bill}"
      puts "Lowest average weekly salary is #{lowest_average_salary_team.title} of #{lowest_average_salary_team.average_weekly_wage_bill}"
      

      teams_in_order_of_total_squad_value = league_teams.sort_by { |team| team.squad_value }
      most_valuable_team = teams_in_order_of_total_squad_value.last
      least_valuable_team = teams_in_order_of_total_squad_value.first
      puts "Most valuable team is #{most_valuable_team.title} valued at #{most_valuable_team.squad_value}"
      puts "Least valuable team is #{least_valuable_team.title} valued at #{least_valuable_team.squad_value}"

      teams_in_order_of_average_player_value = league_teams.sort_by { |team| team.average_team_player_value }
      most_valuable_team_average = teams_in_order_of_average_player_value.last
      least_valuable_team_average = teams_in_order_of_average_player_value.first
      puts "Team with highest average value of players is #{most_valuable_team_average.title} valued at #{most_valuable_team_average.average_team_player_value}"
      puts "Team with lowest average value of players is #{least_valuable_team_average.title} valued at #{least_valuable_team_average.average_team_player_value}"

      teams_sorted_by_size = league_teams.sort_by { |team| team.squad_size }
      biggest_squad = teams_sorted_by_size.last
      smallest_squad = teams_sorted_by_size.first
      puts "Biggest squad is #{biggest_squad.title} with #{biggest_squad.squad_size} players"
      puts "Smallest squad is #{smallest_squad.title} with #{smallest_squad.squad_size} players"
    end
  end
end
