class RemoveContractReferenceFromTeamPlayer < ActiveRecord::Migration
  def change
    remove_column :team_players, :contract_id
  end
end
