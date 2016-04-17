require 'spec_helper'

describe GameWeek do
  let!(:game_week){ GameWeek.create(id: 1, starts_at: Date.today - 2, ends_at: Date.today + 2, league_season_id: 1) }
  let!(:game_week_2){ GameWeek.create(id: 2, starts_at: Date.today, ends_at: Date.today + 4, league_season_id: 1) }

	context "relationships" do
      it {should belong_to(:league_season)}
  		it {should have_many(:player_game_weeks)}
  	end

  	context "validations" do
	  	it "requires a start date" do
	  		expect(game_week).to validate_presence_of(:starts_at)
	  	end

	  	it "requires a end date" do
	  		expect(game_week).to validate_presence_of(:ends_at)
	  	end

	  	it "requires no overlap of dates" do
			expect(game_week_2).to_not be_valid  		
	  	end
  	end
end
