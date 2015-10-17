class CreateGameWeeks < ActiveRecord::Migration
  def change
    create_table :game_weeks do |t|

      t.timestamps
    end
  end
end
