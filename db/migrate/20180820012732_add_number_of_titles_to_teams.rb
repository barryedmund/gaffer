class AddNumberOfTitlesToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :number_of_titles, :integer
  end
end
