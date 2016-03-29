require 'spec_helper'

RSpec.describe "Games", :type => :request do
	let!(:league_season) {create(:league_season)}

  	describe "GET /games" do
    	it "works!" do
      	get league_games_path(league_season.league)
      	expect(response.status).to be(200)
    	end
  	end
end
