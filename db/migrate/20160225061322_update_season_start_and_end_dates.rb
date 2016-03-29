class UpdateSeasonStartAndEndDates < ActiveRecord::Migration
  def change
    remove_column :seasons, :starts_at
    remove_column :seasons, :ends_at
    add_column :seasons, :starts_at, :date
    add_column :seasons, :ends_at, :date
  end
end
