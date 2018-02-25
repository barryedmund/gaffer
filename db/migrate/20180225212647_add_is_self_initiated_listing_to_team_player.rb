class AddIsSelfInitiatedListingToTeamPlayer < ActiveRecord::Migration
  def change
    add_column :team_players, :is_team_player_initiated_listing, :boolean, null: false, default: false
  end
end
