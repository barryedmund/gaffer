require "spec_helper"

RSpec.describe GameWeeksController, :type => :routing do
  let!(:team_player) { create(:team_player) }
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/leagues/#{team_player.team.league.id}/teams/#{team_player.team.id}/team_players/#{team_player.id}/players/#{team_player.player_id}/game_weeks").to route_to("game_weeks#index", :league_id => "1", :team_id => "1", :team_player_id => "1", :player_id => "1")
    end

    it "routes to #show" do
      expect(:get => "/leagues/#{team_player.team.league.id}/teams/#{team_player.team.id}/team_players/#{team_player.id}/players/#{team_player.player_id}/game_weeks/1").to route_to("game_weeks#show", :league_id => "1", :team_id => "1", :team_player_id => "1", :player_id => "1", :id => "1")
    end
  end
end
