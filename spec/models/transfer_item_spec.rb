require 'spec_helper'

describe TransferItem do
  let!(:competition){ create(:competition) }

  let!(:league_1){ League.create(:id => 1, :name => "League 1", :user_id => 1, competition: competition) }
  let!(:league_2){ League.create(:id => 2, :name => "League 2", :user_id => 1) }

  let!(:team_1){Team.create(:id => 1, :title => "Team 1", :league => league_1, :user_id => 1, cash_balance_cents: 20000000)}
  let!(:team_2){Team.create(:id => 2, :title => "Team 2", :league => league_1, :user_id => 2, cash_balance_cents: 1000)}
  let!(:team_3){Team.create(:id => 3, :title => "Team 3", :league => league_2, :user_id => 2, cash_balance_cents: 10000)}
  let!(:team_4){Team.create(:id => 4, :title => "Team 4", :league => league_1, :user_id => 3, :cash_balance_cents => 100)}
  let!(:team_5){Team.create(:id => 5, :title => "Team 5", :league => league_1, :user_id => 4)}

  let!(:player){create(:player)}

  let!(:squad_position){create(:squad_position)}

  let!(:team_player){TeamPlayer.create(:team => team_1, :player => player, :squad_position => squad_position)}

  let!(:transfer){Transfer.create(:primary_team => team_1, :secondary_team => team_2, :primary_team_accepted => true, :secondary_team_accepted => false)}
  
  let!(:transfer_item_with_weird_type){TransferItem.create(:sending_team => team_1, :receiving_team => team_2, :transfer => transfer, :transfer_item_type => "pokemon", :cash_cents => 123456)}
  
  let!(:cash_transfer_item_with_positive_cash){TransferItem.create(:sending_team => team_1, :receiving_team => team_2, :transfer => transfer, :transfer_item_type => "Cash", :cash_cents => 123456)}
  
  let!(:cash_transfer_item_with_null_cash){TransferItem.create(:sending_team => team_1, :receiving_team => team_2, :transfer => transfer, :transfer_item_type => "Cash")}
  
  let!(:cash_transfer_item_with_negative_cash){TransferItem.create(:sending_team => team_1, :receiving_team => team_2, :transfer => transfer, :transfer_item_type => "Cash", :cash_cents => -123456)}
  
  let!(:cash_transfer_item_with_team_player){TransferItem.create(:sending_team => team_1, :receiving_team => team_2, :transfer => transfer, :transfer_item_type => "Cash", :cash_cents => 123456, :team_player => team_player)}
  
  let!(:player_transfer_item_without_team_player){TransferItem.create(:sending_team => team_1, :receiving_team => team_2, :transfer => transfer, :transfer_item_type => "Player")}
  
  let!(:player_transfer_item_with_cash_cents){TransferItem.create(:sending_team => team_1, :receiving_team => team_2, :transfer => transfer, :transfer_item_type => "Player", :cash_cents => 123456, :team_player => team_player)}

  let!(:player_transfer_item_when_player_not_on_sending_team){TransferItem.create(:sending_team => team_2, :receiving_team => team_1, :transfer => transfer, :transfer_item_type => "Player", :team_player => team_player)}

  let!(:transfer_item_teams_not_in_same_league){TransferItem.create(:sending_team => team_1, :receiving_team => team_3, :transfer => transfer, :transfer_item_type => "Cash", :cash_cents => 123456)}

  let!(:transfer_item_same_team){TransferItem.create(:sending_team => team_1, :receiving_team => team_1, :transfer => transfer, :transfer_item_type => "Cash", :cash_cents => 123456)}

  let!(:transfer_item_team_not_enough_money){TransferItem.create(:sending_team => team_4, :receiving_team => team_1, :transfer => transfer, :transfer_item_type => "Cash", :cash_cents => 123456)}

  let!(:transfer_item_teams_not_same_as_transfer_teams){TransferItem.create(:sending_team => team_1, :receiving_team => team_5, :transfer => transfer, :transfer_item_type => "Cash", :cash_cents => 123456)}

  context "relationships" do
    it {should belong_to(:sending_team)}
    it {should belong_to(:receiving_team)}
    it {should belong_to(:transfer)}
    it {should belong_to(:team_player)}
  end

  context "validations" do
    # let!(:transfer_item){TransferItem.create(:sending_team => team_1, :receiving_team => team_2, :transfer => transfer, :transfer_item_type => "Cash", :cash_cents => 100001)}
    user_1 = User.create(first_name: "Test", last_name: "McTest", email: "test@example.com")
    user_2 = User.create(first_name: "Betty", last_name: "McTest", email: "betty@example.com")
    league_1 = League.create(name: "League 1", user: user_1)
    team_1 = Team.create(title: "Team 1", league: league_1, user: user_1, cash_balance_cents: 20000000)
    team_2 = Team.create(title: "Team 2", league: league_1, user: user_2, cash_balance_cents: 5000000)
    transfer_1 = Transfer.create(primary_team: team_1, secondary_team: team_2, primary_team_accepted: true, secondary_team_accepted: false)
    transfer_item = TransferItem.create(sending_team: team_1, receiving_team: team_2, transfer: transfer_1, transfer_item_type: "Cash", cash_cents: 1000000)

    it "validate presence of transfer ID" do
      expect(transfer_item).to validate_presence_of(:transfer)
    end
    it "validate presence of sending team" do
      expect(transfer_item).to validate_presence_of(:sending_team)
    end
    it "validate presence of receiving team" do
      expect(transfer_item).to validate_presence_of(:receiving_team)
    end
    it "validate presence of transfer item type" do
      expect(transfer_item).to validate_presence_of(:transfer_item_type)
    end
    it "validate that type is either 'cash' or 'player'" do
      expect(transfer_item_with_weird_type).to_not be_valid
    end
    it "validate 'cash' with positive cash_cents" do
      expect(cash_transfer_item_with_positive_cash).to be_valid
    end
    it "invalidate 'cash' with null cash_cents" do
      expect(cash_transfer_item_with_null_cash).to_not be_valid
    end
    it "invalidate 'cash' with negative cash_cents" do
      expect(cash_transfer_item_with_negative_cash).to_not be_valid
    end
    it "validate that if 'cash', team_player is null" do
      expect(cash_transfer_item_with_team_player).to_not be_valid
    end
    it "validate that if 'player', team_player is not null" do
      expect(player_transfer_item_without_team_player).to_not be_valid
    end
    it "validate that if 'player', cash_cents is null" do
      expect(player_transfer_item_with_cash_cents).to_not be_valid
    end
    it "validate that team_player is on sending_team" do
      expect(player_transfer_item_when_player_not_on_sending_team).to_not be_valid
    end
    it "validate that teams involved are in the same league" do
      expect(transfer_item_teams_not_in_same_league).to_not be_valid
    end
    it "validate that the sending and receiving is not the same team" do
      expect(transfer_item_same_team).to_not be_valid
    end
    it "validate that the sending has enough money" do
      expect(transfer_item_team_not_enough_money).to_not be_valid
    end
  end
end
