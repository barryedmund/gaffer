class CreateLeagueInvite < ActiveRecord::Migration
  def change
    create_table :league_invites do |t|
      t.references :league
      t.string :email
      t.timestamps
    end
  end
end
