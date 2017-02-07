class AddTransferListingFieldsToTeamPlayer < ActiveRecord::Migration
  def change
    add_column :team_players, :transfer_completes_at, :datetime
    add_column :team_players, :is_voluntary_transfer, :boolean, null: false, default: false
    add_column :team_players, :transfer_minimum_bid, :integer
  end
end
