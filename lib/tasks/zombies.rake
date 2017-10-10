namespace :zombies do
  task :move_subs_to_first_team => :environment do
    Team.where(deleted_at: nil).each do |team|
      if team.league.current_league_season && !GameWeek.has_current_game_week
        puts "-_-_-_-_-_-_-_-"
        puts team.title
        puts "PLAYERS OUT >>>>"
        if team.is_zombie_team
          team.team_players.joins(:squad_position, :player).where('squad_positions.short_name != ? AND team_players.first_team = ? AND players.news != ?', 'SUB', true, '').each do |unavailable_first_team_player|
            unavailable_first_team_player.update_attributes(first_team: false, squad_position: SquadPosition.find_by(short_name: 'SUB'))
            puts "#{unavailable_first_team_player.full_name} (#{unavailable_first_team_player.player.playing_position})"
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
    League.active_leagues.each do |league|
      league.teams.where(deleted_at: nil).order("RANDOM()").each do |team|
        players_with_contract_offers_from_team = team.get_players_with_contract_offers
        if team.is_zombie_team && what_to_sign = team.get_position_to_sign(players_with_contract_offers_from_team)
          free_agent_to_sign = Player.get_most_valuable_unattached_player_at_position(league, what_to_sign, players_with_contract_offers_from_team)
          transfer_listed_player_to_sign = TeamPlayer.get_best_deal_of_transfer_listed_team_players_at_position(team, what_to_sign)
          puts "#{league.name} | #{team.title} | #{team.cash_balance_cents}"
          signing_options = []
          if free_agent_to_sign
            signing_options << {type: "free_agent", object: free_agent_to_sign.full_name, relative_deal_value: (free_agent_to_sign.player_value / Rails.application.config.min_weekly_salary_of_contract).round}
            free_agent_relative_deal_value = (free_agent_to_sign.player_value / Rails.application.config.min_weekly_salary_of_contract).round
            if transfer_listed_player_to_sign
              signing_options << {type: "transfer_listed", object: transfer_listed_player_to_sign.full_name, relative_deal_value: transfer_listed_player_to_sign.relative_deal_value}
            end
          end
          puts " > > signing_options: #{signing_options.inspect}"
          # if free_agent_to_sign && !free_agent_to_sign.has_contract_offer_from_team?(team)
          #   @contract_offer = Contract.new(
          #     team: team,
          #     player: free_agent_to_sign,
          #     starts_at: Date.today,
          #     ends_at: Rails.application.config.min_length_of_contract_days.days.from_now.strftime('%Y-%m-%d'),
          #     weekly_salary_cents: Rails.application.config.min_weekly_salary_of_contract)
          #   if @contract_offer.save
          #     NewsItem.create(league: team.league, news_item_resource_type: 'Contract', news_item_resource_id: @contract_offer.id, body: "#{@contract_offer.player.full_name(true,13)} offered contract")
          #   end
          # end
        end
      end
    end
  end

  task :respond_to_transfer_bids => :environment do
    League.active_leagues.each do |league|
      league.teams.where(deleted_at: nil).order(:created_at).each do |team|
        if team.is_zombie_team
          team.get_active_transfers.where(secondary_team: team, secondary_team_accepted: false).each do |transfer|
            other_team = transfer.get_other_team_involved(team)
            team_debt = team.cash_balance_cents < 0 ? team.cash_balance_cents * -1 : 0
            bid_amount = transfer.get_cash_involved
            team_player_involved = transfer.get_team_player_involved
            is_bid_enough_to_clear_debt = team_debt > 0 ? bid_amount > team_debt : true
            team_player_value = team_player_involved.player.player_value
            decent_bid = team_player_involved.transfer_listed? ? (team_player_list_price * 0.75).round : (team_player_involved.relative_value < 100 ? (team_player_value * 0.75).round : (team_player_value * 1.1)).round
            if transfer.is_winning_bid
              if team_player_involved.transfer_listed?
                team_player_list_price = team_player_involved.transfer_minimum_bid
                is_bid_greater_than_list_price = bid_amount >= team_player_list_price
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
end
