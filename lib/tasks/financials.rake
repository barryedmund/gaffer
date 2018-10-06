namespace :financials do
  #
  # Not a scheduled task
  #
  task :reset_squad_listing_status => :environment do
    puts "Rake task: reset_squad_listing_status"
    Team.all.each do |team|
      team.delist_non_self_listed_team_players if team.should_be_back_in_the_black
    end
  end

  #
  # START: Should just be used as a ONCE_OFF
  #
  task :process_game_week_financials => :environment do
    puts "Rake task: process_game_week_financials"
    this_season = Season.current
    this_season_game_weeks = GameWeek.where(season: this_season).order(:starts_at)
    this_season_game_weeks.each do |game_week|
      if game_week.starts_at < Time.now && game_week.finished && !game_week.financials_processed
        game_week.do_financials
      end
    end
  end
  # END
end
