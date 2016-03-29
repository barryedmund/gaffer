class RemoveLeagueIdFromGame < ActiveRecord::Migration
  def change
    remove_column :games, :league_id
  end
end
