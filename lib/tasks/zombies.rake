namespace :zombies do
  task :move_subs_to_first_team => :environment do
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
      most_recently_finished_gameweek = GameWeek.get_most_recent_finished
      current_season = Season.current.first
      # Go through each team
      league.teams.where(deleted_at: nil).order("RANDOM()").each do |team|
        combined_players = team.get_players_with_contract_offers + team.get_players_in_existing_bids
        # Are they a zombie team and do they need a player?
        if team.is_zombie_team && what_to_sign = team.get_position_to_sign(combined_players)
          puts "#{team.title} (#{what_to_sign})"
          # Sort the player game weeks by value
          PlayerGameWeek.where("game_week_id = ? AND player_value IS NOT NULL", most_recently_finished_gameweek.id).joins(:player).where("players.news = ? AND players.available = ?", '', true).order("player_game_weeks.player_value DESC").each do |pgw|
            # If the player is the right position
            should_randomise = false
            if team.team_players.count < 6 && rand < 0.3
              should_randomise = true
            end
            player_plays = (pgw.player.percentage_of_minutes_played_this_season(current_season) >= 0.5) || (pgw.player.eligible_game_weeks_this_season(current_season) == 0)
            if pgw.player.playing_position == what_to_sign && player_plays && !should_randomise
              team_player = TeamPlayer.where(player: pgw.player).joins(:team).where('teams.league_id = ?', league.id).first
              # If the player belongs to a team
              if team_player
                is_transfer_listed = team_player.transfer_minimum_bid.present?
                # If the player is transfer listed
                if is_transfer_listed
                  team_player_salary = team_player.current_contract.weekly_salary_cents
                  is_transfer_price_reasonable = team_player.transfer_minimum_bid <= (pgw.player_value * 1.1)
                  is_not_on_this_team = team_player.team != team
                  is_reasonable_salary = team_player_salary <= (team.home_game_revenue * 0.1)
                  is_fiscally_responsible = team.end_of_season_financial_position(team_player_salary, team_player.transfer_minimum_bid) > Rails.application.config.min_remaining_for_zombie_after_transfer_bid
                  has_enough_cash = team_player.transfer_minimum_bid < team.cash_balance_cents
                  has_existing_bid = team_player.has_active_transfer_bid_from_team(team)
                  # If the finances match up
                  if is_transfer_price_reasonable && is_not_on_this_team && is_reasonable_salary && is_fiscally_responsible && !has_existing_bid && has_enough_cash
                    puts ">> Has #{team.cash_balance_cents}. Will bid on #{pgw.player.full_name} from #{team_player.team.title} for #{team_player.transfer_minimum_bid}. Will leave team with #{team.end_of_season_financial_position(team_player_salary, team_player.transfer_minimum_bid)} at the end of the season."
                    Transfer.set_up_transfer(team, team_player, team_player.transfer_minimum_bid)
                    break
                  end
                end
              # If the player is a free agent
              else
                puts ">> Has #{team.cash_balance_cents}. Will sign #{pgw.player.full_name} for free. Will leave team with #{team.end_of_season_financial_position(25000)} at the end of the season."
                standard_ends_at = Rails.application.config.min_length_of_contract_days.days.from_now.strftime('%Y-%m-%d')
                standard_salary = Rails.application.config.min_weekly_salary_of_contract
                @contract_offer = Contract.new(team: team, player: pgw.player, starts_at: Date.today, ends_at: standard_ends_at, weekly_salary_cents: standard_salary)
                if @contract_offer.save
                  NewsItem.create(league: team.league, news_item_resource_type: 'Contract', news_item_resource_id: @contract_offer.id, body: "#{@contract_offer.player.full_name(true,13)} offered contract")
                end
                break
              end
            end
          end
        end
      end
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
