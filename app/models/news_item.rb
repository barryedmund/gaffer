class NewsItem < ActiveRecord::Base
  belongs_to :league
  belongs_to :news_item_resource, polymorphic: true
  validates :news_item_resource_type, :news_item_resource_id, presence: true

  def self.fresh_news_items(leagues)
    self.where('news_items.league_id IN (?) AND news_items.created_at >= ?', leagues.all.pluck(:id), 4.days.ago).order(created_at: :desc)
  end
end
