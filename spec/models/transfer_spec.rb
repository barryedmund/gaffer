require 'spec_helper'

describe Transfer do
	let!(:league_1){ League.create(:id => 1, :name => "League 1", :user_id => 1) }
	let!(:league_2){ League.create(:id => 2, :name => "League 2", :user_id => 2) }

	let!(:team_1){Team.create(:id => 1, :title => "Team 1", :league => league_1, :user_id => 1, cash_balance_cents: 200000000)}
	let!(:team_2){Team.create(:id => 2, :title => "Team 2", :league => league_1, :user_id => 2, cash_balance_cents: 200000000)}
	let!(:team_3){Team.create(:id => 3, :title => "Team 3", :league => league_2, :user_id => 2, cash_balance_cents: 200000000)}

  let!(:transfer){Transfer.create(:primary_team => team_1, :secondary_team => team_2, :primary_team_accepted => true, :secondary_team_accepted => false)}

  let!(:team_player) { create(:team_player, :with_contract, team: team_1) }

  let!(:transfer_item_player) { TransferItem.create(transfer: transfer, transfer_item_type: "Player", team_player: team_player, sending_team: team_1, receiving_team: team_2 ) }

  let!(:transfer_item_cash) { TransferItem.create(transfer: transfer, transfer_item_type: "Cash", cash_cents: 100000000, sending_team: team_2, receiving_team: team_1 ) }

	let!(:same_team_transfer){Transfer.create(:primary_team => team_1, :secondary_team => team_1, :primary_team_accepted => true, :secondary_team_accepted => false)}
	let!(:different_league_transfer){Transfer.create(:primary_team => team_1, :secondary_team => team_3, :primary_team_accepted => true, :secondary_team_accepted => false)}
	
	context "relationships" do
		it {should belong_to(:primary_team)}
		it {should belong_to(:secondary_team)}
    it {should have_many(:transfer_items)}
	end
	
	context "validations" do
		it "requires a primary team" do
  		expect(transfer).to validate_presence_of(:primary_team)
  	end
  	it "requires a secondary team" do
  		expect(transfer).to validate_presence_of(:secondary_team)
  	end
  	it "doesn't allow involved teams to be in different leagues" do
  		expect(same_team_transfer).to_not be_valid
  	end
  	it "doesn't allow involved teams to be the same team" do
  		expect(different_league_transfer).to_not be_valid
  	end
  end
end
