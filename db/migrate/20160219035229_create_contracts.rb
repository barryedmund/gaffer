class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.references :team, index: true
      t.references :team_player, index: true, null: true
      t.integer :weekly_salary_cents, limit: 8
      t.date :starts_at
      t.date :ends_at
      t.timestamps
    end
  end
end
