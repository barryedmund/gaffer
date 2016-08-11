class AddFieldsToGameWeeks < ActiveRecord::Migration
  def up
    change_column :game_weeks, :starts_at, :datetime
  end

  def down
    change_column :game_weeks, :starts_at, :date
  end
end
