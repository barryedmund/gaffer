class CreateStadiumModel < ActiveRecord::Migration
  def change
    create_table :stadiums do |t|
      t.references :team
      t.integer :capacity
      t.string :name
      t.timestamps
    end
  end
end
