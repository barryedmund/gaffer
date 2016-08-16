class AddGoalsConcededToPlayerGameWeeks < ActiveRecord::Migration
  def change
    add_column :player_game_weeks, :goals_conceded, :integer
  end
end
