class AddGameReferenceToGameRounds < ActiveRecord::Migration
  def change
  	add_reference :games, :game_round
  end
end
