require 'spec_helper'

describe NewsItemsController do
  
  let!(:user) { create(:user) }  
  let!(:league) { create(:league) }
  let!(:player) { create(:player) } 
  let(:valid_attributes) { { league: league, news_item_resource_type: 'Player', news_item_resource_id: player.id } }
  let(:valid_session) { {} }

  before do
    sign_in(user)
  end

  describe "GET index" do
    it "assigns all as @news_items" do
      news_item = NewsItem.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:news_items)).to eq([news_item])
    end
  end
end
