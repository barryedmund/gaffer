namespace :transfers do

	task :process_free_agent_with_contract_offers => :environment do
		puts "Rake task: process_free_agent_with_contract_offers"
    League.all.each do |league|
      this_league_unsigned_contracts = Contract.joins(:team).where('contracts.signed = ? AND teams.league_id = ?', false, league.id)
      this_league_unsigned_contracts.select('DISTINCT player_id').each do |contract|
        ordered_contracts = this_league_unsigned_contracts.where(player: contract.player).order('contracts.starts_at DESC')
        if ordered_contracts.last.starts_at < 3.days.ago
          best_contract_offer = ordered_contracts.sort_by{ |contract| [-contract.value, contract.created_at] }.first
          team = best_contract_offer.team
          player = best_contract_offer.player
          team_player = TeamPlayer.create(team: team, player: player, squad_position: SquadPosition.find_by(short_name: 'SUB'))
          NewsItem.create(league: league, news_item_resource_type: 'TeamPlayer', news_item_type: 'team_player_signs_contract', news_item_resource_id: team_player.id, body: "#{player.full_name(true,16)} snapped up", content: "Player signs for #{team.title}.")
          best_contract_offer.update_attributes(team_player: team_player, signed: true)
          puts "#{team_player.full_name} just signed for #{team.title}"
          ordered_contracts.where(signed: false).destroy_all
        end
      end
    end
	end

  task :release_players_with_expired_contracts => :environment do
		puts "Rake task: release_players_with_expired_contracts"
		if !GameWeek.has_current_game_week
	    signed_contracts_with_team_players = Contract.where('contracts.signed = ? AND contracts.ends_at < ? AND contracts.team_player_id IS NOT NULL', true, Date.today)
	    signed_contracts_with_team_players.each do |contract|
	      team_player = contract.team_player
	      league = team_player.team.league
	      player = team_player.player
	      team = team_player.team
	      puts "#{team_player.full_name} is being released from #{team.title}..."
	      team_player.destroy
	      NewsItem.create(league: league, news_item_resource_type: 'Player', news_item_type: 'contract_expiry', news_item_resource_id: player.id, body: "#{player.full_name(true,16)} contract expires", content: "Player released from #{team.title}.")
	      puts "... released."
	    end
		end
  end

  task :clean_up_transfers => :environment do
		puts "Rake task: clean_up_transfers"
    empty_transfers = Transfer.includes(:transfer_items).where(:transfer_items => { :id => nil })
    stale_transfers = Transfer.where('updated_at < ? AND (primary_team_accepted = ? OR secondary_team_accepted = ?)', 1.week.ago, false, false)
    (empty_transfers | stale_transfers).each(&:destroy)
  end

  task :process_transfer_listings => :environment do
		puts "Rake task: process_transfer_listings"
    if !GameWeek.has_current_game_week
      TeamPlayer.transfer_listed_with_offers_and_past_completion_date.each do |team_player|
        winning_transfer = team_player.get_winning_transfer
				if winning_transfer
        	winning_transfer.complete_a_transfer_listing
        	team_player.reset_transfer_attributes
				elsif team_player.transfer_completes_at.present?
					team_player.update_attributes!(transfer_completes_at: nil)
				end
      end
    end
  end

	task :transfer_list_unhappy_player => :environment do
		puts "Rake task: transfer_list_unhappy_player"
		League.active_leagues.each do |league|
			uphappy_team_players ||= []
			# TeamPlayers whose value went up in the last game week & who aren't injured & whose happiness is below X
			league.team_players.each do |tp| #{tp.real_minutes_played_recently(5) > 225} #{tp.was_on_bench_most_recently} #{tp.full_name}"
				if tp.player.news.blank? && tp.did_value_go_up && tp.happiness < Rails.application.config.team_player_happiness_threshold && tp.transfer_minimum_bid.blank? && tp.real_minutes_played_recently(5) > 225 && tp.was_on_bench_most_recently
					uphappy_team_players << tp
				end
			end
			if rand < 0.5 && uphappy_team_players.count > 0
				uphappy_team_players_as_relation = TeamPlayer.where(id: uphappy_team_players.map(&:id))
				most_valuable_unhappy_team_player = uphappy_team_players_as_relation.sort_by{ |team_player| team_player.player.player_value }.last
				most_valuable_unhappy_team_player.force_transfer_list(true)
				NewsItem.create(league: league, news_item_resource_type: 'TeamPlayer', news_item_type: 'team_player_forces_listing', news_item_resource_id: most_valuable_unhappy_team_player.id, body: "#{most_valuable_unhappy_team_player.full_name(true)} forces listing.", content: "Unhappy with #{most_valuable_unhappy_team_player.team.user.last_name} over lack of playing time.")
				puts "#{most_valuable_unhappy_team_player.full_name} / happiness: #{most_valuable_unhappy_team_player.happiness} / team: #{most_valuable_unhappy_team_player.team.title} / player value: #{most_valuable_unhappy_team_player.player.player_value}"
			end
		end
	end
end
