class RemovePlayerFromGameWeeks < ActiveRecord::Migration
  def change
  	remove_column :game_weeks, :sequence_number
  end
end
