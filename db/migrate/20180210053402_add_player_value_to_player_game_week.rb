class AddPlayerValueToPlayerGameWeek < ActiveRecord::Migration
  def change
    add_column :player_game_weeks, :player_value, :integer
  end
end
