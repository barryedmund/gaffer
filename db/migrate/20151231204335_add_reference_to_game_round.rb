class AddReferenceToGameRound < ActiveRecord::Migration
  def change
    add_reference :game_rounds, :season
    add_reference :game_rounds, :league
  end
end
