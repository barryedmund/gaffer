class CreateTeamPlayers < ActiveRecord::Migration
  def change
    create_table :team_players do |t|
      t.references :team, index: true

      t.timestamps
    end
  end
end
