class AddBodyToNewsItem < ActiveRecord::Migration
  def change
    add_column :news_items, :body, :text
  end
end
