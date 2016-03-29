class RemoveSeasonIdFromGameRound < ActiveRecord::Migration
  def change
    remove_column :game_rounds, :season_id
  end
end
