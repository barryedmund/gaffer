class ChangeScoringColumnTypesInPlayerGameWeeks < ActiveRecord::Migration
  def up
    change_column :player_game_weeks, :goals, :float
  end

  def down
    change_column :player_game_weeks, :goals, :integer
  end
end
