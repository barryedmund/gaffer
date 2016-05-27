class AddCompetitionReferenceToPlayer < ActiveRecord::Migration
  def change
    add_reference :players, :competition
  end
end
