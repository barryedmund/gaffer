class AddCompletedToSeason < ActiveRecord::Migration
  def change
    add_column :seasons, :is_completed, :boolean, null: false, default: false
  end
end
