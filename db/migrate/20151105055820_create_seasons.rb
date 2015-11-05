class CreateSeasons < ActiveRecord::Migration
  def change
    create_table :seasons do |t|
      t.string :description
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end
    add_reference :game_weeks, :season
  end
end
