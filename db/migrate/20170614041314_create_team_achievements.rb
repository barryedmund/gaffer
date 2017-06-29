class CreateTeamAchievements < ActiveRecord::Migration
  def change
    create_table :team_achievements do |t|
      t.references :achievement
      t.references :team
      t.references :league_season
      t.string :details
      t.timestamps
    end
  end
end
