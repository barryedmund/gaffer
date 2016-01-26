class CreateGameRounds < ActiveRecord::Migration
  def change
    create_table :game_rounds do |t|
    	t.integer :game_round_number
    	t.references :season
    	t.references :league
    	t.timestamps
    end
  end
end
