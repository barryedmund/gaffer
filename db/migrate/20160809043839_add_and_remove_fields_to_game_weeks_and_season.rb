class AddAndRemoveFieldsToGameWeeksAndSeason < ActiveRecord::Migration
  def change
    add_column :game_weeks, :finished, :boolean, default: false
    remove_column :game_weeks, :ends_at
    remove_column :seasons, :starts_at
  end
end
