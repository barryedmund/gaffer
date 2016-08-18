require 'spec_helper'

describe NewsItem do
  let!(:news_item){create(:news_item)}
  context "validations" do
    it "requires a resource type" do
      expect(news_item).to validate_presence_of(:news_item_resource_type)
    end
    it "requires a resource ID" do
      expect(news_item).to validate_presence_of(:news_item_resource_id)
    end
  end
end
