class AddLeagueIdToGame < ActiveRecord::Migration
  def change
  	add_reference :leagues, :game
  end
end
