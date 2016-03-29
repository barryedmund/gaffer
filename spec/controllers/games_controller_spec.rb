require 'spec_helper'

RSpec.describe GamesController, :type => :controller do
  let!(:season) { create(:season) }
  let!(:league) { create(:league) }
  let!(:league_season) { LeagueSeason.create(season: season, league: league) }
  let!(:game_week) { GameWeek.create(starts_at: Date.today + 100, ends_at: Date.today + 107, league_season: league_season, season: season) }
  let!(:home_team) { Team.create(title: "Home Team", league: league_season.league) }
  let!(:away_team) { Team.create(title: "Away Team", league: league_season.league) }
  let!(:game_round) { create(:game_round) }
  let(:valid_attributes) { { home_team: home_team, away_team: away_team, game_week: game_week, game_round: game_round} }
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
end
