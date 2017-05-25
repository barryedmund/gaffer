namespace :wrap_up_season do
  task :distribute_end_of_season_cash => :environment do
    LeagueSeason.all.each do |league_season|
      
      if league_season.is_ready_to_be_wrapped_up
        puts "------ #{league_season.league.name} ------"
        league_standings = league_season.league.get_standings

        league_standings.each_with_index do |standings_row, index|
          end_of_season_reward = (league_standings.length - index) * Rails.application.config.reward_per_position_at_end_of_season
          standings_row[:team_record].add_cash(end_of_season_reward)
          puts "#{standings_row[:team_record].title} gets #{end_of_season_reward}. New balance: #{standings_row[:team_record].cash_balance_cents}"
          NewsItem.create(league: league_season.league, news_item_resource_type: 'Team', news_item_type: 'end_of_season_reward', news_item_resource_id: standings_row[:team_record].id, body: end_of_season_reward)
        end
        # league_season.update_attributes(is_completed: true)
      end
    end
  end
end
