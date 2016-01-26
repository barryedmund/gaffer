class AddGameRoundNumberToGameRound < ActiveRecord::Migration
  def change
  	add_column :game_rounds, :game_round_number, :integer
  end
end
