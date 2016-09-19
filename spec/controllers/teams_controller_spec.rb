require 'spec_helper'

describe TeamsController do
  let(:valid_attributes) { { "title" => "MyString", league: league } }
  let(:valid_attributes_post) { { id: 2, title: "MyString", user_id: user_2.id, league_id: league_2.id, cash_balance_cents: 12345 } }
  let(:valid_session) { {} }
  let!(:user) { create(:user) }
  let!(:user_2) { create(:user) }
  let!(:team) { create(:team) }
  let!(:league) { create(:league) }
  let!(:league_2) { create(:league) }

  before do
    sign_in(user)
  end

  describe "GET show" do
    it "assigns the requested team as @team for the logged in user" do
      team = user.teams.create! valid_attributes
      get :show, {:league_id => team.to_param, :id => team.to_param}, valid_session
      assigns(:team).should eq(team)
      expect(assigns(:team).user).to eq(user)
    end
  end

  describe "GET new" do
    it "assigns a new team as @team for the logged in user" do
      get :new, {:league_id => 1}, valid_session
      assigns(:team).should be_a_new(Team)
      expect(assigns(:team).user).to eq(user)
    end
  end

  describe "GET edit" do
    it "assigns the requested team as @team" do
      team = user.teams.create! valid_attributes
      get :edit, {:league_id => team.to_param, :id => team.to_param}, valid_session
      assigns(:team).should eq(team)
      expect(assigns(:team).user).to eq(user)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Team" do
        expect {
          post :create, { :league_id => league_2.id, :team => valid_attributes_post }, valid_session
        }.to change(Team, :count).by(1)
      end

      it "assigns a newly created team as @team" do
        post :create, { :league_id => league_2.id, :team => valid_attributes_post }, valid_session
        assigns(:team).should be_a(Team)
        assigns(:team).should be_persisted
      end

      it "redirects to the league's teams" do
        post :create, { :league_id => league_2.id, :team => valid_attributes_post }, valid_session
        team = Team.last
        response.should redirect_to(league_path(team.league_id))
      end

      it "create a team for the current user" do
        post :create, { :league_id => league_2.id, :team => valid_attributes_post }, valid_session
        team = Team.last
        expect(team.user).to eq(user)
      end

    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved team as @team" do
        Team.any_instance.stub(:save).and_return(false)
        post :create, {:league_id => 1, :team => { "title" => "invalid value" }}, valid_session
        assigns(:team).should be_a_new(Team)
      end

      it "re-renders the 'new' template" do
        Team.any_instance.stub(:save).and_return(false)
        post :create, {:league_id => 1, :team => { "title" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested team" do
        team = user.teams.create! valid_attributes
        Team.any_instance.should_receive(:update).with({ "title" => "MyString" })
        put :update, {:id => team.to_param, :league_id => team.league_id, :team => { "title" => "MyString" }}, valid_session
      end

      it "assigns the requested team as @team" do
        team = user.teams.create! valid_attributes
        put :update, {:id => team.to_param, :league_id => team.league_id, :team => valid_attributes}, valid_session
        assigns(:team).should eq(team)
      end

      it "redirects to the team" do
        team = user.teams.create! valid_attributes
        put :update, {:id => team.to_param, :league_id => team.league_id, :team => valid_attributes}, valid_session
        response.should redirect_to(league_team_path)
      end
    end

    describe "with invalid params" do
      it "assigns the team as @team" do
        team = user.teams.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Team.any_instance.stub(:save).and_return(false)
        put :update, {:id => team.to_param, :league_id => team.league_id, :team => { "title" => "invalid value" }}, valid_session
        assigns(:team).should eq(team)
      end

      it "re-renders the 'edit' template" do
        team = user.teams.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Team.any_instance.stub(:save).and_return(false)
        put :update, {:id => team.to_param, :league_id => team.league_id, :team => { "title" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested team" do
      team = user.teams.create! valid_attributes
      expect {
        delete :destroy, {:id => team.to_param, :league_id => team.league_id}, valid_session
      }.to change(Team, :count).by(-1)
    end

    it "redirects to the teams list" do
      team = user.teams.create! valid_attributes
      delete :destroy, {:id => team.to_param, :league_id => team.league_id }, valid_session
      response.should redirect_to(league_teams_url)
    end
  end
end
