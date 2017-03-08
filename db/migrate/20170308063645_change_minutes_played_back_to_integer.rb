class ChangeMinutesPlayedBackToInteger < ActiveRecord::Migration
  def up
    change_column :player_game_weeks, :minutes_played, :integer
  end

  def down
    change_column :player_game_weeks, :minutes_played, :float
  end
end
