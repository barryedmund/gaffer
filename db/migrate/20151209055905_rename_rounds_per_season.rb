class RenameRoundsPerSeason < ActiveRecord::Migration
  def change
  	rename_column :competitions, :rounds_per_season, :game_weeks_per_season
  end
end
