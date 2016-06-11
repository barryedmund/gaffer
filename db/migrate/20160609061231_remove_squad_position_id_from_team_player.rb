class RemoveSquadPositionIdFromTeamPlayer < ActiveRecord::Migration
  def change
    remove_column :team_players, :squad_position_id
  end
end
