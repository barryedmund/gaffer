require 'spec_helper'

describe GameWeek do
	let(:valid_attributes){
  		{
    		season_id: 1,
    		starts_at: "2015-11-04 21:58:20",
    		ends_at: "2016-07-04 21:58:20"
  		}
  	}

	context "relationships" do
  		it {should belong_to(:season)}
  		it {should have_many(:player_game_weeks)}
  	end

  	context "validations" do
  		let(:game_week) {
  			GameWeek.new(valid_attributes)
	  	}
	  	
	  	before do
	  		GameWeek.create(valid_attributes)
	  	end

	  	it "requires a season ID" do
	  		expect(game_week).to validate_presence_of(:season_id)
	  	end

	  	it "requires a start date" do
	  		expect(game_week).to validate_presence_of(:starts_at)
	  	end

	  	it "requires a end date" do
	  		expect(game_week).to validate_presence_of(:ends_at)
	  	end
  	end
end