class AddSquadPositionToTeamPlayers < ActiveRecord::Migration
  def change
    add_reference :team_players, :squad_position, index: true
  end
end
