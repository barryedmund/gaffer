class CreatePlayerLineups < ActiveRecord::Migration
  def change
    create_table :player_lineups do |t|
    	t.references :team
    	t.references :player_game_week
      t.timestamps
    end
  end
end
