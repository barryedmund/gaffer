require 'spec_helper'

RSpec.describe GamesController, :type => :controller do
  let!(:league) { create(:league) }
  let!(:home_team) { Team.create(title: "Home Team", league: league) }
  let!(:away_team) { Team.create(title: "Away Team", league: league) }
  let!(:game_week) { create(:game_week) }
  let!(:game_round) { create(:game_round) }
  let(:valid_attributes) { { home_team: home_team, away_team: away_team, game_week: game_week, game_round: game_round, league: league } }
  let(:invalid_attributes) { { home_team: "", away_team: "", game_week: "" } }

  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all games as @games" do
      game = Game.create! valid_attributes
      get :index, {:league_id => game.get_league}, valid_session
      expect(assigns(:games)).to eq([game])
    end
  end

  describe "GET show" do
    it "assigns the requested game as @game" do
      game = Game.create! valid_attributes
      get :show, {:id => game.to_param, :league_id => game.get_league}, valid_session
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
