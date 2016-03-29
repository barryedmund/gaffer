class AddLeagueSeasonToGameWeekAndGameROund < ActiveRecord::Migration
  def change
    add_reference :game_weeks, :league_season, index: true
    add_reference :game_rounds, :league_season, index: true
  end
end
