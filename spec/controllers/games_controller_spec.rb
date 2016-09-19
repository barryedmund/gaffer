require 'spec_helper'

RSpec.describe GamesController, :type => :controller do
  let!(:user) { create(:user) }
  let!(:season) { create(:season) }
  let!(:league) { create(:league) }
  let!(:home_team) { Team.create(id: 1, title: "Home Team", league: league) }
  let!(:away_team) { Team.create(id: 2, title: "Away Team", league: league, user: user) }
  let!(:league_season) { LeagueSeason.create(season: season, league: league) }
  let!(:game_week) { GameWeek.create(starts_at: Date.today + 100, ends_at: Date.today + 107, season: season, game_week_number: 1) }
  let!(:game_round) { GameRound.create(game_round_number: 1, league_season: league_season) }
  let(:valid_attributes) { { home_team: home_team, away_team: away_team, game_week: game_week, game_round: game_round} }
  let(:invalid_attributes) { { home_team: "", away_team: "", game_week: "" } }

  let(:valid_session) { {} }

  before do
    sign_in(user)
  end
  
  describe "GET index" do
    it "assigns all games as @games" do
      game = Game.joins(game_round: :league_season).where('league_seasons.league_id = ?', league.id)
      get :index, {:league_id => league.id}, valid_session
      expect(assigns(:games)).to eq(game)
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
