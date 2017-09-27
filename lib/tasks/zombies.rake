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
      puts "--#{league.name}--"
      league.teams.where(deleted_at: nil).order("RANDOM()").each do |team|
        players_with_contract_offers_from_team = team.get_players_with_contract_offers
        if team.is_zombie_team && what_to_sign = team.get_position_to_sign(players_with_contract_offers_from_team)
          who_to_sign = Player.get_most_valuable_unattached_player_at_position(league, what_to_sign, players_with_contract_offers_from_team)
          puts "#{players_with_contract_offers_from_team.inspect}"
          if !who_to_sign.has_contract_offer_from_team?(team)
            @contract_offer = Contract.new(
              team: team,
              player: who_to_sign,
              starts_at: Date.today,
              ends_at: Rails.application.config.min_length_of_contract_days.days.from_now.strftime('%Y-%m-%d'),
              weekly_salary_cents: Rails.application.config.min_weekly_salary_of_contract)
            if @contract_offer.save
              NewsItem.create(league: team.league, news_item_resource_type: 'Contract', news_item_resource_id: @contract_offer.id, body: "#{@contract_offer.player.full_name(true,13)} offered contract")
              puts "#{team.title}: #{team.formation_with_subs} Offered: #{who_to_sign.full_name}"
            end
          end
        end
      end
      puts "_-_-_-_-_-_-_"
    end
  end

  task :respond_to_transfer_bids => :environment do
    League.active_leagues.each do |league|
      puts ""
      puts "#{league.name}"
      league.teams.where(deleted_at: nil).each do |team|
        if team.is_zombie_team
          puts " > > #{team.title}"
          puts " > > > > #{team.cash_balance_cents}"
          team.get_active_transfers.each do |transfer|
            puts " > > > > #{transfer.get_team_player_involved.full_name}"
            puts " > > > > > > Forced transfer: #{transfer.get_team_player_involved.is_force_transfer_listed?}"
            puts " > > > > > > Winning bid: #{transfer.is_winning_bid}"
            puts " > > > > > > Offer: #{transfer.get_cash_involved}"
            puts " > > > > > > Value: #{transfer.get_team_player_involved.player.player_value}"
            puts " > > > > > > Minimum bid: #{transfer.get_team_player_involved.transfer_minimum_bid}"
            puts " > > > > > > Relative value: #{transfer.get_team_player_involved.relative_value}"
          end
        end
      end
    end    
  end
end
