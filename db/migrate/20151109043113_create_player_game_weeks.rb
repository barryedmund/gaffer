class CreatePlayerGameWeeks < ActiveRecord::Migration
  def change
    create_table :player_game_weeks do |t|
      t.integer :minutes_played
      t.references :game_week, index: true
      t.references :player, index: true
    end
  end
end
