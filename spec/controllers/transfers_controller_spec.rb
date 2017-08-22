require 'spec_helper'

describe TransfersController do
  let!(:league) { create(:league) }
  let!(:primary_user) { create(:user,) }
  let!(:secondary_user) { create(:user) }
  let!(:primary_team) { create(:team, user_id: primary_user.id, league_id: league.id, cash_balance_cents: 2000000) }
  let!(:secondary_team) { create(:team, user_id: secondary_user.id, league_id: league.id) }
  let!(:team_player) { create(:team_player, team_id: secondary_team.id) }
  let!(:user) { create(:user) }
  let(:valid_session) { {} }
  let(:attributes) { {
    primary_team_id: primary_team.id,
    secondary_team_id: secondary_team.id,
    primary_team_accepted: true,
    secondary_team_accepted: false,
    transfer_item: {
      sending_team_id: primary_team.id,
      receiving_team_id: secondary_team.id,
      transfer_item_type: 'Player',
      team_player_id: team_player.id,
      cash_cents: 1500000} } }

  before do
    sign_in(user)
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Transfer" do
        expect { post :create, { league_id: league.id, transfer: attributes }, valid_session }.to change(Transfer, :count).by(1)
      end
    end

    describe "with valid params" do
      before do
        primary_team.update_attributes(cash_balance_cents: 1000000)
      end

      it "creates a new Transfer" do
        expect { post :create, { league_id: league.id, transfer: attributes }, valid_session }.to change(Transfer, :count).by(0)
      end
    end

  end
end
