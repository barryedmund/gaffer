class AddPlayerToGameWeeks < ActiveRecord::Migration
  def change
    add_reference :game_weeks, :player, index: true
  end
end
