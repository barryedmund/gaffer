class RenameNewsItemTypeColumn < ActiveRecord::Migration
  def up
    rename_column :news_items, :type, :news_item_type
  end

  def down
    rename_column :news_items, :news_item_type, :type
  end
end
