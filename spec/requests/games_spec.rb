require 'spec_helper'

RSpec.describe "Games", :type => :request do
  let!(:user) { create(:user) }
  let!(:season) { create(:season) }
  let!(:league) { create(:league) }
  let!(:home_team) { Team.create(id: 1, title: "Home Team", league: league) }
  let!(:away_team) { Team.create(id: 2, title: "Away Team", league: league, user: user) }
  let!(:league_season) { LeagueSeason.create(season: season, league: league) }

  	describe "GET /games" do
    	it "works!" do
      	get league_games_path(league_season.league)
      	expect(response.status).to be(200)
    	end
  	end
end
