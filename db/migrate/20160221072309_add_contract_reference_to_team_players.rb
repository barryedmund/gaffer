class AddContractReferenceToTeamPlayers < ActiveRecord::Migration
  def change
    add_reference :team_players, :contract, index: true
  end
end
