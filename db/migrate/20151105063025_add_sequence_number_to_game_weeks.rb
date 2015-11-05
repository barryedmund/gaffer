class AddSequenceNumberToGameWeeks < ActiveRecord::Migration
	def change
  		add_column :game_weeks, :sequence_number, :int
  		add_column :game_weeks, :starts_at, :datetime
  		add_column :game_weeks, :ends_at, :datetime
  		add_index :game_weeks, :sequence_number
  	end
end
