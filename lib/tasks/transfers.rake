namespace :transfers do

	task :process_free_agent_with_contract_offers => :environment do
    League.all.each do |league|
      this_league_unsigned_contracts = Contract.joins(:team).where('contracts.signed = ? AND teams.league_id = ?', false, league.id) 
      this_league_unsigned_contracts.select('DISTINCT player_id').each do |contract|
        ordered_contracts = this_league_unsigned_contracts.where(player: contract.player).order('contracts.starts_at DESC')
        if ordered_contracts.last.starts_at < 3.days.ago
          best_contract_offer = ordered_contracts.sort_by{ |contract| [-contract.value, contract.created_at] }.first
          team_player = TeamPlayer.create(team: best_contract_offer.team, player: best_contract_offer.player, squad_position: SquadPosition.find_by(short_name: 'SUB'))
          best_contract_offer.update_attributes(team_player: team_player, signed: true)
          puts "#{team_player.full_name} just signed for #{best_contract_offer.team.title}"
          ordered_contracts.where(signed: false).destroy_all
        end
      end
    end
	end

  task :release_players_with_expired_contracts => :environment do
    signed_contracts_with_team_players = Contract.where('contracts.signed = ? AND contracts.ends_at < ? AND contracts.team_player_id IS NOT NULL', true, Date.today)
    signed_contracts_with_team_players.each do |contract|
      puts "#{contract.team_player.full_name} is being released from #{contract.team.title}..."
      contract.team_player.destroy
      puts "... released."
    end
  end

  task :clean_up_transfers => :environment do
    empty_transfers = Transfer.includes(:transfer_items).where(:transfer_items => { :id => nil })
    stale_transfers = Transfer.where('updated_at < ? AND (primary_team_accepted = ? OR secondary_team_accepted = ?)', 1.week.ago, false, false)
    (empty_transfers | stale_transfers).each(&:destroy)
  end

  task :process_transfer_listings => :environment do
    if !GameWeek.has_current_game_week
      TeamPlayer.transfer_listed_with_offers_and_past_completion_date.each do |team_player|
        winning_transfer = team_player.get_winning_transfer
        winning_transfer.complete_a_transfer_listing
        puts "#{team_player.full_name} / #{winning_transfer.get_cash_transfer_item.cash_cents}"
        team_player.reset_transfer_attributes
      end
    end
  end
end
