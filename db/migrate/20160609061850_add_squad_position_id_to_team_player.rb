class AddSquadPositionIdToTeamPlayer < ActiveRecord::Migration
  def change
    add_reference :team_players, :squad_position
  end
end
