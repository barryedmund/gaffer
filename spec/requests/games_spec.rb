require 'spec_helper'

RSpec.describe "Games", :type => :request do
	let!(:league_1){ create(:league) }
	let!(:team_1){ Team.create(:id => 1, :title => "Team 1", :league => league_1, :user_id => 1) }
	let!(:team_2){ Team.create(:id => 2, :title => "Team 2", :league => league_1, :user_id => 2) }

  	describe "GET /games" do
    	it "works! (now write some real specs)" do
      		get league_games_path(league_1)
      		expect(response.status).to be(200)
    	end
  	end
end
