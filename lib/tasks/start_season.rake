namespace :start_season do
  task :create_games_for_league_season => :environment do
    if current_season = Season.current.first
      League.active_leagues.each do |league|
        if LeagueSeason.where(league: league, season: current_season).count == 0
          LeagueSeason.create(league: league, season: current_season)
        end
      end
    end
  end
end
