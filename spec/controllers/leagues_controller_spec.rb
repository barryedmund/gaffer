require 'spec_helper'

RSpec.describe LeaguesController, :type => :controller do
  let!(:competition) { create(:competition) }
  let(:valid_attributes) { { name: "MyLeague", user: user, competition: competition} }
  let(:valid_attributes_post) { { id: 2, name: "MyLeague", user_id: user.id, competition_id: competition.id } }
  let(:invalid_attributes) { skip("Add a hash of attributes invalid for your model") }
  let(:valid_session) { {} }
  let!(:user) { create(:user) }
  let!(:competition) { create(:competition) }

  before do
    sign_in(user)
  end

  describe "GET index" do
    it "assigns all leagues as @leagues" do
      league = League.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:leagues)).to eq([league])
    end
  end

  describe "GET show" do
    it "assigns the requested league as @league" do
      league = League.create! valid_attributes
      get :show, {:id => league.to_param}, valid_session
      expect(assigns(:league)).to eq(league)
    end
  end

  describe "GET new" do
    it "assigns a new league as @league" do
      get :new, {}, valid_session
      expect(assigns(:league)).to be_a_new(League)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new League" do
        expect { post :create, {:league => valid_attributes_post}, valid_session }.to change(League, :count).by(1)
      end

      it "assigns a newly created league as @league" do
        post :create, {:league => valid_attributes_post}, valid_session
        expect(assigns(:league)).to be_a(League)
        expect(assigns(:league)).to be_persisted
      end

      it "redirects to the created league" do
        post :create, {:league => valid_attributes_post}, valid_session
        league = League.last
        expect(response).to redirect_to(new_league_team_path(league.id))
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) {
        { name: "MyUpdatedLeague", user: user }
      }

      it "updates the requested league" do
        league = League.create! valid_attributes
        put :update, {:id => league.to_param, :league => new_attributes}, valid_session
        league.reload
        expect(response).to redirect_to(league)
      end

      it "assigns the requested league as @league" do
        league = League.create! valid_attributes
        put :update, {:id => league.to_param, :league => valid_attributes}, valid_session
        expect(assigns(:league)).to eq(league)
      end

      it "redirects to the league" do
        league = League.create! valid_attributes
        put :update, {:id => league.to_param, :league => valid_attributes}, valid_session
        expect(response).to redirect_to(league)
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested league" do
      league = League.create! valid_attributes
      expect {
        delete :destroy, {:id => league.to_param}, valid_session
      }.to change(League, :count).by(-1)
    end

    it "redirects to the leagues list" do
      league = League.create! valid_attributes
      delete :destroy, {:id => league.to_param}, valid_session
      expect(response).to redirect_to(leagues_url)
    end
  end

end
