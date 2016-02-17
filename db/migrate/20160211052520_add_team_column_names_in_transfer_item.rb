class AddTeamColumnNamesInTransferItem < ActiveRecord::Migration
  def change
    add_column :transfer_items, :sending_team_id, :integer
    add_column :transfer_items, :receiving_team_id, :integer
  end
end
