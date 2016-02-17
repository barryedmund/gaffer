class RenameTransferItemType < ActiveRecord::Migration
  def change
    rename_column :transfer_items, :type, :transfer_item_type
  end
end
