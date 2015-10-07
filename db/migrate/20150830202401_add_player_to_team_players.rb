class AddPlayerToTeamPlayers < ActiveRecord::Migration
  def change
    add_reference :team_players, :player, index: true
  end
end
