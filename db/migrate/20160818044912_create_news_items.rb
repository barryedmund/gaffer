class CreateNewsItems < ActiveRecord::Migration
  def change
    create_table :news_items do |t|
      t.references :league
      t.integer :news_item_resource_id
      t.string :news_item_resource_type
      
      t.timestamps
    end
  end
end
