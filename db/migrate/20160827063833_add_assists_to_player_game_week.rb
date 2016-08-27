class AddAssistsToPlayerGameWeek < ActiveRecord::Migration
  def change
    add_column :player_game_weeks, :assists, :integer
  end
end
