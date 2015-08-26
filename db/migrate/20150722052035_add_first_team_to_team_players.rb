class AddFirstTeamToTeamPlayers < ActiveRecord::Migration
  def change
  	add_column :team_players, :first_team, :boolean, :default => false
  end
end
