class ChangeColumnDataTypes < ActiveRecord::Migration
  def change
  	change_column :game_weeks, :starts_at, :date
  	change_column :game_weeks, :ends_at, :date
  end
end
