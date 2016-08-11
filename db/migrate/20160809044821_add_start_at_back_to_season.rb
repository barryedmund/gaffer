class AddStartAtBackToSeason < ActiveRecord::Migration
  def change
    add_column :seasons, :starts_at, :date
  end
end
