class RemovePlayerReferenceFromGameWeek < ActiveRecord::Migration
  def change
    remove_column :game_weeks, :player_id
  end
end
