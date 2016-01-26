class AddLeagueIdToGames < ActiveRecord::Migration
  def change
  	add_reference :games, :league
  end
end
