class AddCashCentsToTransferItem < ActiveRecord::Migration
  def up
    add_column :transfer_items, :cash_cents, :integer, limit: 8
  end
end
