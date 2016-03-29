class RemoveLeagueFromGameRound < ActiveRecord::Migration
  def change
    remove_column :game_rounds, :league_id
  end
end
