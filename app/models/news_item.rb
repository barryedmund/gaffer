class NewsItem < ActiveRecord::Base
  belongs_to :league
  belongs_to :news_item_resource, polymorphic: true
  validates :news_item_resource_type, :news_item_resource_id, presence: true
end
