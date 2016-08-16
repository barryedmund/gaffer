namespace :financials do
  # 
  # Should just be used as a ONCE_OFF
  # 
  task :process_game_week_financials => :environment do 
    this_season = Season.current
    this_season_game_weeks = GameWeek.where(season: this_season).order(:starts_at)
    this_season_game_weeks.each do |game_week|
      if game_week.starts_at < Time.now && !game_week.finished
        game_week.do_financials
      end
    end
  end
end
