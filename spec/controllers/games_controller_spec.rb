require 'spec_helper'

RSpec.describe GamesController, :type => :controller do
  let!(:league) { create(:league) }
  let!(:home_team) { Team.create(title: "Home Team", league: league) }
  let!(:away_team) { Team.create(title: "Away Team", league: league) }
  let!(:game_week) { create(:game_week) }
  let(:valid_attributes) { { home_team: home_team, away_team: away_team, game_week: game_week } }
  let(:invalid_attributes) { { home_team: "", away_team: "", game_week: "" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # GamesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all games as @games" do
      game = Game.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:games)).to eq([game])
    end
  end

  describe "GET show" do
    it "assigns the requested game as @game" do
      game = Game.create! valid_attributes
      get :show, {:id => game.to_param}, valid_session
      expect(assigns(:game)).to eq(game)
    end
  end

  describe "GET new" do
    
  end

  describe "POST create" do
    describe "with valid params" do
      
    end

    describe "with invalid params" do
      
    end
  end
end
