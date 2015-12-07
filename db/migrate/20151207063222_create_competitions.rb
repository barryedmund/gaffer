class CreateCompetitions < ActiveRecord::Migration
  def change
    create_table :competitions do |t|
      t.string :country_code
      t.string :description
      t.integer :rounds_per_season

      t.timestamps
    end
  end
end
