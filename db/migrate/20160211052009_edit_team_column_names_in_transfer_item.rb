class EditTeamColumnNamesInTransferItem < ActiveRecord::Migration
  def up
    remove_column :transfer_items, :sending_team_id_id
    remove_column :transfer_items, :receiving_team_id_id
  end
end
