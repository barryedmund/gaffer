class MakeTransferItemCashCentsBigInt < ActiveRecord::Migration
  def up
    add_column :transfer_items, :cash_cents, limit: 8
  end

  def up
    remove_column :transfer_items, :cash_cents
  end
end
