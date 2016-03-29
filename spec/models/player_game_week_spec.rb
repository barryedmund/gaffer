require 'spec_helper'

describe PlayerGameWeek do
  let!(:season) { create(:season) }
  let!(:game_week) { season.game_weeks.first }
  let!(:player) { create(:player) }
	let!(:player_game_week_1) { PlayerGameWeek.create(player: player, game_week: game_week, minutes_played: 90) }

	context "relationships" do
  		it { should belong_to(:player) } 		
  		it { should belong_to(:game_week) }
  		it { should have_many(:player_lineups) }
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
