class DropAuctions < ActiveRecord::Migration
  def up
    drop_table :auctions
  end
end
