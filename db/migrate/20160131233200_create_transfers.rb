class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
    	t.integer :primary_team_id
    	t.integer :secondary_team_id
    	t.boolean :primary_team_accepted
    	t.boolean :secondary_team_accepted
      t.timestamps
    end
  end
end
