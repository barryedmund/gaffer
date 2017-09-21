require 'spec_helper'
require 'support/authentication_helpers'

RSpec.describe TransfersController, :type => :controller do
  let!(:league) { create(:league) }
  let!(:primary_user) { create(:user) }
  let!(:secondary_user) { create(:user) }
  let!(:primary_team) { create(:team, user_id: primary_user.id, league_id: league.id, cash_balance_cents: 2000000) }
  let!(:secondary_team) { create(:team, user_id: secondary_user.id, league_id: league.id) }
  let!(:team_player) { create(:team_player, team_id: secondary_team.id) }
  let!(:team_player_2) { create(:team_player, :with_contract, team_id: secondary_team.id) }
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

  let(:transfer) { create(:transfer,
    primary_team_id: primary_team.id,
    secondary_team_id: secondary_team.id,
    primary_team_accepted: false,
    secondary_team_accepted: true) }

  let(:transfer_item_cash) { create(:transfer_item,
    transfer_id: transfer.id,
    sending_team_id: primary_team.id,
    receiving_team_id: secondary_team.id,
    transfer_item_type: 'Cash',
    team_player_id: nil,
    cash_cents: 1500000) }

  let(:transfer_item_player) { create(:transfer_item,
    transfer_id: transfer.id,
    sending_team_id: secondary_team.id,
    receiving_team_id: primary_team.id,
    transfer_item_type: 'Player',
    team_player_id: team_player_2.id,
    cash_cents: nil) }

  describe "POST create" do
    before do
      sign_in(primary_user)
    end
    describe "with valid params" do
      it "creates a new Transfer" do
        expect { post :create, { league_id: league.id, transfer: attributes }, valid_session }.to change(Transfer, :count).by(1)
      end
    end

    describe "with not enough cash" do
      before do
        primary_team.update_attributes(cash_balance_cents: 1000000)
      end

      it "doesn't create a new Transfer" do
        expect { post :create, { league_id: league.id, transfer: attributes }, valid_session }.to change(Transfer, :count).by(0)
      end
    end

    describe "when team_player has been involuntarily transfer listed" do
      before do
        team_player.update_attributes(transfer_minimum_bid: 1230000, is_voluntary_transfer: false)
      end

      it "sets transfer_completes_at" do
        post :create, { league_id: league.id, transfer: attributes }, valid_session
        team_player.reload
        expect(team_player.transfer_completes_at).to_not eq(nil)
      end
    end

    describe "when team_player has been voluntarily transfer listed and bid is high" do
      before do
        team_player.update_attributes(transfer_minimum_bid: 1230000, is_voluntary_transfer: true)
      end

      it "sets transfer_completes_at" do
        post :create, { league_id: league.id, transfer: attributes }, valid_session
        team_player.reload
        expect(team_player.transfer_completes_at).to_not eq(nil)
      end
    end

    describe "when team_player has been voluntarily transfer listed and bid is low" do
      before do
        team_player.update_attributes(transfer_minimum_bid: 2000000, is_voluntary_transfer: true)
      end

      it "does not set transfer_completes_at" do
        post :create, { league_id: league.id, transfer: attributes }, valid_session
        team_player.reload
        expect(team_player.transfer_completes_at).to eq(nil)
      end
    end
  end

  describe "PATCH change_response" do
    describe "primary_team the one accepting the offer" do
      before do
        sign_in(primary_user)
      end
      it "team player goes to new team" do
        transfer.save
        transfer_item_player.save
        transfer_item_cash.save
        patch :change_response, { league_id: league.id, id: transfer.id }, valid_session
        transfer_item_player.reload
        expect(transfer_item_player.team_player.team).to eq(transfer_item_player.receiving_team)
      end
    end
    describe "secondary_team the one accepting the offer" do
      before do
        transfer.update_attributes(secondary_team_accepted: false, primary_team_accepted: true)
        sign_in(secondary_user)
      end
      it "team player goes to new team" do
        transfer.save
        transfer_item_player.save
        transfer_item_cash.save
        patch :change_response, { league_id: league.id, id: transfer.id }, valid_session
        transfer_item_player.reload
        expect(transfer_item_player.team_player.team).to eq(transfer_item_player.receiving_team)
      end
    end
  end
end
