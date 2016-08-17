class AddRealTeamToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :real_team_short_name, :string
  end
end
