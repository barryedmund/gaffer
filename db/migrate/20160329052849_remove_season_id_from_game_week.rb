class RemoveSeasonIdFromGameWeek < ActiveRecord::Migration
  def change
    remove_column :game_weeks, :season_id
  end
end
