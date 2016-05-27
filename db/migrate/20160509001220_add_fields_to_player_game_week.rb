class AddFieldsToPlayerGameWeek < ActiveRecord::Migration
  def change
    add_column :player_game_weeks, :goals, :integer
    add_column :player_game_weeks, :clean_sheet, :boolean
    add_index :players, :pl_player_code
  end
end
