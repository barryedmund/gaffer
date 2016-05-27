class RemoveLeagueSeasonReferenceFromGameWeek < ActiveRecord::Migration
  def change
    remove_column :game_weeks, :league_season_id
  end
end
