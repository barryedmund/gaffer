namespace :zombies do
  task :move_subs_to_first_team => :environment do
    puts "Rake task: move_subs_to_first_team"
    Team.where(deleted_at: nil).each do |team|
      if team.league.current_league_season && !GameWeek.has_current_game_week
        puts "-_-_-_-_-_-_-_-"
        puts team.title
        puts "PLAYERS OUT >>>>"
        if team.is_zombie_team
          team.all_first_team_team_players.each do |first_team_player|
            first_team_player.move_to_subs_bench
            puts "#{first_team_player.full_name} (#{first_team_player.player.playing_position})"
          end
        end
        puts "PLAYERS IN <<<<"
        while team.sub_to_move_to_first_team
          # The method return true or false so nothing goes in here
        end
        puts "-_-_-_-_-_-_-_-"
      end
    end
  end

  task :sign_players => :environment do
    puts "Rake task: sign_players"
    # For each league
    League.active_leagues.each do |league|
      league.sign_players_for_zombies
    end
  end

  task :respond_to_transfer_bids => :environment do
    puts "Rake task: respond_to_transfer_bids"
    League.active_leagues.each do |league|
      league.teams.where(deleted_at: nil).order(:created_at).each do |team|
        if team.is_zombie_team
          team.get_active_transfers.where(secondary_team: team, secondary_team_accepted: false).each do |transfer|
            other_team = transfer.get_other_team_involved(team)
            team_debt = team.cash_balance_cents < 0 ? team.cash_balance_cents * -1 : 0
            puts transfer.inspect
            bid_amount = transfer.get_cash_involved
            team_player_involved = transfer.get_team_player_involved
            is_bid_enough_to_clear_debt = team_debt > 0 ? bid_amount > team_debt : true
            team_player_value = team_player_involved.player.player_value
            decent_bid = team_player_involved.transfer_listed? ? (team_player_involved.transfer_minimum_bid * 0.75).round : (team_player_involved.relative_value < 100 ? (team_player_value * 0.75).round : (team_player_value * 1.1)).round
            if transfer.is_winning_bid
              if team_player_involved.transfer_listed?
                is_bid_greater_than_list_price = bid_amount >= team_player_involved.transfer_minimum_bid
                is_bid_decent = bid_amount >= decent_bid
                if is_bid_greater_than_list_price
                  # Do nothing
                elsif is_bid_decent && is_bid_enough_to_clear_debt
                  transfer.complete_a_transfer_listing
                elsif transfer.get_other_team_involved(team).cash_balance_cents < decent_bid
                  # Do nothing
                else
                  transfer.make_counter_offer(team, decent_bid)
                end
              else
                is_bid_decent = bid_amount >= decent_bid
                if is_bid_decent
                  transfer.update_attributes(secondary_team_accepted: true)
                  transfer.complete_transfer if transfer.transfer_completed?
                elsif other_team.cash_balance_cents < decent_bid
                  # Do nothing
                else
                  transfer.make_counter_offer(team, decent_bid)
                end
              end
            else
              counter_offer = [(team_player_involved.get_winning_transfer.get_cash_involved).round, decent_bid].max
              if other_team.cash_balance_cents < counter_offer
                # Do nothing
              else
                transfer.make_counter_offer(team, counter_offer)
              end
            end
          end
        end
      end
    end
  end

  task :expand_stadium => :environment do
    puts "Rake task: expand_stadium"
    League.active_leagues.each do |league|
      league.teams.where(deleted_at: nil).order(:created_at).each do |team|
        if team.is_zombie_team && !team.get_position_to_sign && (team.end_of_season_financial_position >= 0) && !GameWeek.has_current_game_week && rand < 0.1
          exact_affordable_expansion = team.max_stadium_expansion(team.cash_balance_cents * Rails.application.config.zombie_percentage_spend_on_stadium_expansion)
          rounded_affordable_expansion = ((exact_affordable_expansion.to_f / 50).floor) * 50
          team.expand_stadium(rounded_affordable_expansion)
          puts "#{team.title} stadium by #{rounded_affordable_expansion} seats. New capacity is #{team.stadium.capacity}."
        end
      end
    end
  end
end
