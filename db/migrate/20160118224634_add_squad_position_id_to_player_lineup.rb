class AddSquadPositionIdToPlayerLineup < ActiveRecord::Migration
  def change
  	add_reference :player_lineups, :squad_position
  end
end
