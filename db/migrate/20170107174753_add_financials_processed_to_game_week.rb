class AddFinancialsProcessedToGameWeek < ActiveRecord::Migration
  def change
    add_column :game_weeks, :financials_processed, :boolean, default: false
  end
end
