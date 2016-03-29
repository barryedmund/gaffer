class CreateLeagueSeasons < ActiveRecord::Migration
  def change
    create_table :league_seasons do |t|
      t.references :season, index: true
      t.references :league, index: true
      t.timestamps
    end
  end
end
