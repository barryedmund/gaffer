class AddCompetitionRefToSeasons < ActiveRecord::Migration
  def change
    add_reference :seasons, :competition, index: true
  end
end
