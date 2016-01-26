require 'spec_helper'

describe GameWeek do
	let!(:season){ create(:season) }
	let!(:game_week_1){ GameWeek.create(:id => 1, :starts_at => Date.today - 2, :ends_at => Date.today + 2, :season => season) }
	let!(:game_week_2){ GameWeek.create(:id => 2, :starts_at => Date.today, :ends_at => Date.today + 4, :season => season) }

	context "relationships" do
  		it {should belong_to(:season)}
  		it {should have_many(:player_game_weeks)}
  	end

  	context "validations" do
	  	it "requires a season ID" do
	  		expect(game_week_1).to validate_presence_of(:season_id)
	  	end

	  	it "requires a start date" do
	  		expect(game_week_1).to validate_presence_of(:starts_at)
	  	end

	  	it "requires a end date" do
	  		expect(game_week_1).to validate_presence_of(:ends_at)
	  	end

	  	it "requires no overlap of dates" do
			expect(game_week_2).to_not be_valid  		
	  	end
  	end
end