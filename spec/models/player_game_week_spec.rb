require 'spec_helper'

describe PlayerGameWeek do
	let!(:player_game_week_1) { create(:player_game_week) }
	let!(:player_game_week_2) { create(:player_game_week) }

	context "relationships" do
  		it { should belong_to(:player) }
  		
  		it { should belong_to(:game_week) }
  	end
  	
  	context "validations" do
	  	it "requires a Player ID" do
	  		expect(player_game_week_1).to validate_presence_of(:player_id)
	  	end

	  	it "requires a GameWeek ID" do
	  		expect(player_game_week_1).to validate_presence_of(:game_week_id)
	  	end

	  	it "requires a unique Player & GameWeek combo" do
			should validate_uniqueness_of(:game_week_id).scoped_to(:player_id)
	  	end
	end
end