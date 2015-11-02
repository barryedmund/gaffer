class CreateSquadPositions < ActiveRecord::Migration
  def change
    create_table :squad_positions do |t|
      t.string :short_name

      t.timestamps
    end
  end
end
