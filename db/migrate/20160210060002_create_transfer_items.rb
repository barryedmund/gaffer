class CreateTransferItems < ActiveRecord::Migration
  def change
    create_table :transfer_items do |t|
      t.references :transfer, index: true
      t.string :type
      t.references :sending_team_id, index: true
      t.references :receiving_team_id, index: true
      t.references :team_player, index: true, null: true
      t.integer :cash_cents, null: true

      t.timestamps
    end
  end
end
