namespace :transfers do
	task :process_free_agent_with_contract_offers => :environment do
    League.all.each do |league|
      this_league_unsigned_contracts = Contract.joins(:team).where('contracts.signed = ? AND teams.league_id = ?', false, league.id) 
      this_league_unsigned_contracts.select('DISTINCT player_id').each do |contract|
        ordered_contracts = this_league_unsigned_contracts.where(player: contract.player).order(starts_at: :desc)
        if ordered_contracts.last.starts_at < 3.days.ago
          best_contract_offer = ordered_contracts.sort_by{ |contract| contract.value }.reverse.first
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
end
