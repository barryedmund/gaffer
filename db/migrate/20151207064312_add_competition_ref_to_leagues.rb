class AddCompetitionRefToLeagues < ActiveRecord::Migration
  def change
    add_reference :leagues, :competition, index: true
  end
end
