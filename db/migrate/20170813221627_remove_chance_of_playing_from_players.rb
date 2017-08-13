class RemoveChanceOfPlayingFromPlayers < ActiveRecord::Migration
  def change
    remove_column :players, :chance_of_playing
  end
end
