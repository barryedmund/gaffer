require "spec_helper"

describe PlayersController do
  let!(:team_player) { create(:team_player) }
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/leagues/#{team_player.team.league.id}/teams/#{team_player.team.id}/team_players/#{team_player.id}/players").to route_to("players#index", :league_id => "1", :team_id => "1", :team_player_id => "1")
    end

    it "routes to #show" do
      expect(:get => "/leagues/#{team_player.team.league.id}/teams/#{team_player.team.id}/team_players/#{team_player.id}/players/1").to route_to("players#show", :league_id => "1", :team_id => "1", :team_player_id => "1", :id => "1")
    end
  end
end
