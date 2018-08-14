class AddIsCompleteToGames < ActiveRecord::Migration
  def change
    add_column :games, :is_complete, :boolean, null: false, default: false
  end
end
