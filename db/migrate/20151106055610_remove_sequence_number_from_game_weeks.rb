class RemoveSequenceNumberFromGameWeeks < ActiveRecord::Migration
  def change
    remove_column :game_weeks, :sequence_number, :string
  end
end
