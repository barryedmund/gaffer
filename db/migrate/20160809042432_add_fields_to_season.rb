class AddFieldsToSeason < ActiveRecord::Migration
  def up
    change_column :seasons, :starts_at, :datetime
  end

  def down
    change_column :seasons, :starts_at, :date
  end
end
