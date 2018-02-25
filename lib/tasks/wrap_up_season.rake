namespace :wrap_up_season do
  task :distribute_end_of_season_cash => :environment do
    season_should_be_wrapped_up = false
    season_to_complete = Season.current.first
    LeagueSeason.all.each do |league_season|
      if league_season.is_ready_to_be_wrapped_up
        season_should_be_wrapped_up = true
        season_to_complete = league_season.season
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
          team.delist_non_self_listed_team_players if team.should_be_back_in_the_black
        end
      end
    end
    if season_should_be_wrapped_up && season_to_complete
      season_to_complete.update_attributes(is_completed: true)
    end
  end


  # Run once unless new achievements have been created in which case just replace the array contents with the new awards
  task :create_achievements => :environment do
    [:most_valuable_goalkeeper,
    :best_defensive_contribution_goalkeeper,
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

    :richest_team,
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
    :smallest_squad,

    :galacticos].each do |award|
      new_achievement = Achievement.create(award_type: award, name: award.to_s.titleize)
      puts new_achievement.inspect
    end
  end

  task :end_of_season_achievements => :environment do
    current_season = Season.current.first
    League.all.each do |league|
      puts "Gathering data for #{league.name}..."
      league_season = LeagueSeason.where(league: league, season: current_season).first
      league_teams = league.teams
      league_players = Player.where(available: true).where(id: (Player.joins(team_players: [:team => :league]).where('leagues.id = ?', league.id) ).map(&:id))
      league_teams_team_players = league_teams.joins(:team_players)
      league_team_players = TeamPlayer.joins(:team).where('teams.league_id = ?', league.id)

      ['Goalkeeper', 'Defender', 'Midfielder', 'Forward'].each do |position|
        puts "... doing the #{position.pluralize} awards..."
        league_players_at_position = league_players.where(playing_position: position)
        league_team_players_at_position = league_team_players.joins(:player).where('players.playing_position = ?', position)

        most_valuable_at_position = league_players_at_position.sort_by{ |player| player.player_value }.last
        most_valuable_at_position_team = league_teams_team_players.where('team_players.player_id = ?', most_valuable_at_position.id).first

        total_defensive_contribution_at_position = league_players_at_position.sort_by{ |player| player.total_defensive_contribution(current_season) }.last
        total_defensive_contribution_at_position_team = league_teams_team_players.where('team_players.player_id = ?', total_defensive_contribution_at_position.id).first

        total_attacking_contribution_at_position = league_players_at_position.sort_by{ |player| player.total_attacking_contribution(current_season) }.last
        total_attacking_contribution_at_position_team = league_teams_team_players.where('team_players.player_id = ?', total_attacking_contribution_at_position.id).first

        highest_paid_team_player = league_team_players_at_position.sort_by{ |team_player| team_player.current_contract.weekly_salary_cents }.last

        team_player_values = league_team_players_at_position.sort_by{ |team_player| team_player.relative_value }
        overrated_team_player = team_player_values.first
        underrated_team_player = team_player_values.last

        if position == "Goalkeeper"
          { :most_valuable_goalkeeper => [most_valuable_at_position_team, most_valuable_at_position.full_name],
            :best_defensive_contribution_goalkeeper => [total_defensive_contribution_at_position_team, total_defensive_contribution_at_position.full_name],
            :highest_paid_goalkeeper => [highest_paid_team_player.team, "#{highest_paid_team_player.full_name}, #{Presenters::Contract.new(highest_paid_team_player.current_contract).salary_to_currency}"],
            :worst_signing_goalkeeper => [overrated_team_player.team, overrated_team_player.full_name],
            :best_signing_goalkeeper => [underrated_team_player.team, underrated_team_player.full_name] }.each do |award, details|
              team_achievement = TeamAchievement.create(
                achievement: Achievement.where("award_type = ?", Achievement.award_types[award]).first,
                team: details[0],
                league_season: league_season,
                details: details[1])
              puts "#{award} created: #{team_achievement.valid?}"
          end
        elsif position == "Defender"
          { :most_valuable_defender => [most_valuable_at_position_team, most_valuable_at_position.full_name],
            :best_defensive_contribution_defender => [total_defensive_contribution_at_position_team, total_defensive_contribution_at_position.full_name],
            :best_attacking_contribution_defender => [total_attacking_contribution_at_position_team, total_attacking_contribution_at_position.full_name],
            :highest_paid_defender => [highest_paid_team_player.team, "#{highest_paid_team_player.full_name}, #{Presenters::Contract.new(highest_paid_team_player.current_contract).salary_to_currency}"],
            :worst_signing_defender => [overrated_team_player.team, overrated_team_player.full_name],
            :best_signing_defender => [underrated_team_player.team, underrated_team_player.full_name] }.each do |award, details|
              team_achievement = TeamAchievement.create(
                achievement: Achievement.where("award_type = ?", Achievement.award_types[award]).first,
                team: details[0],
                league_season: league_season,
                details: details[1])
              puts "#{award} created: #{team_achievement.valid?}"
          end
        elsif position == "Midfielder"
          { :most_valuable_midfielder => [most_valuable_at_position_team, most_valuable_at_position.full_name],
            :best_defensive_contribution_midfielder => [total_defensive_contribution_at_position_team, total_defensive_contribution_at_position.full_name],
            :best_attacking_contribution_midfielder => [total_attacking_contribution_at_position_team, total_attacking_contribution_at_position.full_name],
            :highest_paid_midfielder => [highest_paid_team_player.team, "#{highest_paid_team_player.full_name}, #{Presenters::Contract.new(highest_paid_team_player.current_contract).salary_to_currency}"],
            :worst_signing_midfielder => [overrated_team_player.team, overrated_team_player.full_name],
            :best_signing_midfielder => [underrated_team_player.team, underrated_team_player.full_name] }.each do |award, details|
              team_achievement = TeamAchievement.create(
                achievement: Achievement.where("award_type = ?", Achievement.award_types[award]).first,
                team: details[0],
                league_season: league_season,
                details: details[1])
              puts "#{award} created: #{team_achievement.valid?}"
          end
        elsif position == "Forward"
          { :most_valuable_forward => [most_valuable_at_position_team, most_valuable_at_position.full_name],
            :best_attacking_contribution_forward => [total_attacking_contribution_at_position_team, total_attacking_contribution_at_position.full_name],
            :highest_paid_forward => [highest_paid_team_player.team, "#{highest_paid_team_player.full_name}, #{Presenters::Contract.new(highest_paid_team_player.current_contract).salary_to_currency}"],
            :worst_signing_forward => [overrated_team_player.team, overrated_team_player.full_name],
            :best_signing_forward => [underrated_team_player.team, underrated_team_player.full_name] }.each do |award, details|
              team_achievement = TeamAchievement.create(
                achievement: Achievement.where("award_type = ?", Achievement.award_types[award]).first,
                team: details[0],
                league_season: league_season,
                details: details[1])
              puts "#{award} created: #{team_achievement.valid?}"
          end
        end
      end

      # Overall player awards
      puts "... doing the Overall awards..."
      most_valuable_overall = league_players.sort_by{ |player| player.player_value }.last
      most_valuable_overall_team = league_teams_team_players.where('team_players.player_id = ?', most_valuable_overall.id).first
      team_achievement = TeamAchievement.create(
                achievement: Achievement.where("award_type = ?", Achievement.award_types[:most_valuable_overall]).first,
                team: most_valuable_overall_team,
                league_season: league_season,
                details: most_valuable_overall.full_name)
      puts "most_valuable_overall created: #{team_achievement.valid?}"

      # best_signing_overall
      # worst_signing_overall
      # highest_paid_overall
      # best_attacking_contribution_overall
      # best_defensive_contribution_overall
      team_player_values_overall = league_team_players.sort_by{ |team_player| team_player.relative_value }
      overrated_team_player_overall = team_player_values_overall.first
      underrated_team_player_overall = team_player_values_overall.last
      highest_paid_team_player_overall = league_team_players.sort_by{ |team_player| team_player.current_contract.weekly_salary_cents }.last
      total_defensive_contribution_overall = league_players.sort_by{ |player| player.total_defensive_contribution(current_season) }.last
      total_defensive_contribution_overall_team = league_teams_team_players.where('team_players.player_id = ?', total_defensive_contribution_overall.id).first
      total_attacking_contribution_overall = league_players.sort_by{ |player| player.total_attacking_contribution(current_season) }.last
      total_attacking_contribution_overall_team = league_teams_team_players.where('team_players.player_id = ?', total_attacking_contribution_overall.id).first

      { :best_signing_overall => [underrated_team_player_overall.team, underrated_team_player_overall.full_name],
        :worst_signing_overall => [overrated_team_player_overall.team, overrated_team_player_overall.full_name],
        :highest_paid_overall => [highest_paid_team_player_overall.team, "#{highest_paid_team_player_overall.full_name}, #{Presenters::Contract.new(highest_paid_team_player_overall.current_contract).salary_to_currency}"],
        :best_defensive_contribution_overall => [total_defensive_contribution_overall_team, total_defensive_contribution_overall.full_name],
        :best_attacking_contribution_overall => [total_attacking_contribution_overall_team, total_attacking_contribution_overall.full_name] }.each do |award, details|
          team_achievement = TeamAchievement.create(
            achievement: Achievement.where("award_type = ?", Achievement.award_types[award]).first,
            team: details[0],
            league_season: league_season,
            details: details[1])
          puts "#{award} created: #{team_achievement.valid?}"
      end


      # Team awards
      teams_in_order_of_cash = league_teams.order(:cash_balance_cents)
      richest_team = teams_in_order_of_cash.last
      poorest_team = teams_in_order_of_cash.first
      puts "... doing the Team awards..."
      team_achievement = TeamAchievement.create(
                achievement: Achievement.where("award_type = ?", Achievement.award_types[:richest_team]).first,
                team: richest_team,
                league_season: league_season,
                details: Presenters::Team.new(richest_team).cash_balance_to_currency)
      puts "richest_team created: #{team_achievement.valid?}"
      team_achievement = TeamAchievement.create(
                achievement: Achievement.where("award_type = ?", Achievement.award_types[:poorest_team]).first,
                team: poorest_team,
                league_season: league_season,
                details: Presenters::Team.new(poorest_team).cash_balance_to_currency)
      puts "poorest_team created: #{team_achievement.valid?}"

      teams_in_order_of_total_wage_bill = league_teams.sort_by { |team| team.total_weekly_wage_bill }
      highest_wage_bill_team = teams_in_order_of_total_wage_bill.last
      lowest_wage_bill_team = teams_in_order_of_total_wage_bill.first
      team_achievement = TeamAchievement.create(
                achievement: Achievement.where("award_type = ?", Achievement.award_types[:highest_total_weekly_salary_team]).first,
                team: highest_wage_bill_team,
                league_season: league_season,
                details: Presenters::Team.new(highest_wage_bill_team).convert_number_to_currency(highest_wage_bill_team.total_weekly_wage_bill))
      puts "highest_total_weekly_salary_team created: #{team_achievement.valid?}"
      team_achievement = TeamAchievement.create(
                achievement: Achievement.where("award_type = ?", Achievement.award_types[:lowest_total_weekly_salary_team]).first,
                team: lowest_wage_bill_team,
                league_season: league_season,
                details: Presenters::Team.new(lowest_wage_bill_team).convert_number_to_currency(lowest_wage_bill_team.total_weekly_wage_bill))
      puts "lowest_total_weekly_salary_team created: #{team_achievement.valid?}"

      teams_in_order_of_average_weekly_salary = league_teams.sort_by { |team| team.average_weekly_wage_bill }
      highest_average_salary_team = teams_in_order_of_average_weekly_salary.last
      lowest_average_salary_team = teams_in_order_of_average_weekly_salary.first
      team_achievement = TeamAchievement.create(
                achievement: Achievement.where("award_type = ?", Achievement.award_types[:highest_average_weekly_salary_team]).first,
                team: highest_average_salary_team,
                league_season: league_season,
                details: Presenters::Team.new(highest_average_salary_team).convert_number_to_currency(highest_average_salary_team.average_weekly_wage_bill))
      puts "highest_average_weekly_salary_team created: #{team_achievement.valid?}"
      team_achievement = TeamAchievement.create(
                achievement: Achievement.where("award_type = ?", Achievement.award_types[:lowest_average_weekly_salary_team]).first,
                team: lowest_average_salary_team,
                league_season: league_season,
                details: Presenters::Team.new(lowest_average_salary_team).convert_number_to_currency(lowest_average_salary_team.average_weekly_wage_bill))
      puts "lowest_average_weekly_salary_team created: #{team_achievement.valid?}"

      teams_in_order_of_total_squad_value = league_teams.sort_by { |team| team.squad_value }
      most_valuable_team = teams_in_order_of_total_squad_value.last
      least_valuable_team = teams_in_order_of_total_squad_value.first
      team_achievement = TeamAchievement.create(
                achievement: Achievement.where("award_type = ?", Achievement.award_types[:most_valuable_team]).first,
                team: most_valuable_team,
                league_season: league_season,
                details: Presenters::Team.new(most_valuable_team).convert_number_to_currency(most_valuable_team.squad_value))
      puts "most_valuable_team created: #{team_achievement.valid?}"
      team_achievement = TeamAchievement.create(
                achievement: Achievement.where("award_type = ?", Achievement.award_types[:least_valuable_team]).first,
                team: least_valuable_team,
                league_season: league_season,
                details: Presenters::Team.new(least_valuable_team).convert_number_to_currency(least_valuable_team.squad_value))
      puts "least_valuable_team created: #{team_achievement.valid?}"

      teams_in_order_of_average_player_value = league_teams.sort_by { |team| team.average_team_player_value }
      most_valuable_team_average = teams_in_order_of_average_player_value.last
      least_valuable_team_average = teams_in_order_of_average_player_value.first
      team_achievement = TeamAchievement.create(
                achievement: Achievement.where("award_type = ?", Achievement.award_types[:highest_average_value_of_players_team]).first,
                team: most_valuable_team_average,
                league_season: league_season,
                details: Presenters::Team.new(most_valuable_team_average).convert_number_to_currency(most_valuable_team_average.average_team_player_value))
      puts "highest_average_value_of_players_team created: #{team_achievement.valid?}"
      team_achievement = TeamAchievement.create(
                achievement: Achievement.where("award_type = ?", Achievement.award_types[:lowest_average_value_of_players_team]).first,
                team: least_valuable_team_average,
                league_season: league_season,
                details: Presenters::Team.new(least_valuable_team_average).convert_number_to_currency(least_valuable_team_average.average_team_player_value))
      puts "lowest_average_value_of_players_team created: #{team_achievement.valid?}"

      teams_sorted_by_size = league_teams.sort_by { |team| team.squad_size }
      biggest_squad = teams_sorted_by_size.last
      smallest_squad = teams_sorted_by_size.first
      team_achievement = TeamAchievement.create(
                achievement: Achievement.where("award_type = ?", Achievement.award_types[:biggest_squad]).first,
                team: biggest_squad,
                league_season: league_season,
                details: biggest_squad.squad_size)
      puts "biggest_squad created: #{team_achievement.valid?}"
      team_achievement = TeamAchievement.create(
                achievement: Achievement.where("award_type = ?", Achievement.award_types[:smallest_squad]).first,
                team: smallest_squad,
                league_season: league_season,
                details: smallest_squad.squad_size)
      puts "smallest_squad created: #{team_achievement.valid?}"

      # galacticos
      teams_sorted_by_galactico_value = league_teams.sort_by { |team| team.galacticos_value }
      galacticos = teams_sorted_by_galactico_value.last
      team_achievement = TeamAchievement.create(
                achievement: Achievement.where("award_type = ?", Achievement.award_types[:galacticos]).first,
                team: galacticos,
                league_season: league_season,
                details: galacticos.galacticos_names)
      puts "galacticos created: #{team_achievement.valid?}"
      puts "... done."
    end
  end
end
