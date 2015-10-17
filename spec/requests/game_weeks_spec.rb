require 'spec_helper'

RSpec.describe "GameWeeks", :type => :request do
	let!(:team_player) {create(:team_player)}
  	describe "GET /game_weeks" do
    	it "works! (now write some real specs)" do
      		get league_team_team_player_player_game_weeks_path(team_player.team.league, team_player.team, team_player, team_player.player)
      		expect(response.status).to be(200)
    	end
  	end
end
