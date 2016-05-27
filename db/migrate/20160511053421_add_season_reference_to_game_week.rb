class AddSeasonReferenceToGameWeek < ActiveRecord::Migration
  def change
    add_reference :game_weeks, :season, index: true
  end
end
