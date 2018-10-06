namespace :daily_news do
  task :create_high_value_free_agent_news_item => :environment do
    puts "Rake task: create_high_value_free_agent_news_item"
    League.all.each do |league|
      high_value_free_agent = Player.get_all_unattached_players_sorted_by_value(league)
      NewsItem.create(league: league, news_item_resource_type: 'Player', news_item_type: 'high_value_free_agent', news_item_resource_id: high_value_free_agent.id, body: "Free agent of interest")
    end
  end
end
