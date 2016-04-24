class RemoveSeasonAndLeagueReferenceFromGameRounds < ActiveRecord::Migration
  def change
    remove_column :game_rounds, :season_id
    remove_column :game_rounds, :league_id
  end
end
