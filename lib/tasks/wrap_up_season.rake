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
end
