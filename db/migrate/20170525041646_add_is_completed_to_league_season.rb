class AddIsCompletedToLeagueSeason < ActiveRecord::Migration
  def change
    add_column :league_seasons, :is_completed, :boolean, null: false, default: false
  end
end
