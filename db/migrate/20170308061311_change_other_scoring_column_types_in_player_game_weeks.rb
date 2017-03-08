class ChangeOtherScoringColumnTypesInPlayerGameWeeks < ActiveRecord::Migration
  def up
    change_column :player_game_weeks, :minutes_played, :float
    change_column :player_game_weeks, :goals_conceded, :float
    change_column :player_game_weeks, :assists, :float
  end

  def down
    change_column :player_game_weeks, :minutes_played, :integer
    change_column :player_game_weeks, :goals_conceded, :integer
    change_column :player_game_weeks, :assists, :integer
  end
end
