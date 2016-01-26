class RemoveGameIdFromLeague < ActiveRecord::Migration
  def change
  	remove_column :leagues, :game_id
  end
end
