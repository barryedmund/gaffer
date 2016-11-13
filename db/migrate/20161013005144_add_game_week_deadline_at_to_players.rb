class AddGameWeekDeadlineAtToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :game_week_deadline_at, :datetime
  end
end
