class CreateAuctions < ActiveRecord::Migration
  def change
    create_table :auctions do |t|
      t.references :team_player
      t.integer :minimum_bid
      t.boolean :is_voluntary
      t.boolean :is_active
      t.datetime :active_until
      t.timestamps
    end
  end
end
