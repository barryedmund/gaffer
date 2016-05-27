class AddGameWeekNumberToGameWeek < ActiveRecord::Migration
  def change
    add_column :game_weeks, :game_week_number, :integer
  end
end
