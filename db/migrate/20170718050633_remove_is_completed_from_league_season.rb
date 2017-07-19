class RemoveIsCompletedFromLeagueSeason < ActiveRecord::Migration
  def change
    remove_column :league_seasons, :is_completed
  end
end
