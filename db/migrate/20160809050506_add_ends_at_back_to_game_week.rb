class AddEndsAtBackToGameWeek < ActiveRecord::Migration
  def change
    add_column :game_weeks, :ends_at, :datetime
  end
end
