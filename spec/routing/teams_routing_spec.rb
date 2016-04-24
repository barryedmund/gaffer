require "spec_helper"

describe TeamsController do
  let!(:team) { create(:team) }
  describe "routing" do

    it "routes to #index" do
      get("leagues/#{team.league_id}/teams").should route_to("teams#index", :league_id => "#{team.league_id}")
    end

    it "routes to #new" do
      get("leagues/#{team.league_id}/teams/new").should route_to("teams#new", :league_id => "#{team.league_id}")
    end

    it "routes to #show" do
      get("leagues/#{team.league_id}/teams/1").should route_to("teams#show", :league_id => "#{team.league_id}", :id => "1")
    end

    it "routes to #edit" do
      get("leagues/#{team.league_id}/teams/1/edit").should route_to("teams#edit", :league_id => "#{team.league_id}", :id => "1")
    end

    it "routes to #create" do
      post("leagues/#{team.league_id}/teams").should route_to("teams#create", :league_id => "#{team.league_id}")
    end

    it "routes to #update" do
      put("leagues/#{team.league_id}/teams/1").should route_to("teams#update", :league_id => "#{team.league_id}", :id => "1")
    end

    it "routes to #destroy" do
      delete("leagues/#{team.league_id}/teams/1").should route_to("teams#destroy", :league_id => "#{team.league_id}", :id => "1")
    end

  end
end
