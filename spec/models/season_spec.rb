require 'spec_helper'

describe Season do

	let!(:season){ create(:season) }

	context "relationships" do
	  it { should have_many(:game_weeks) }
	  it { should belong_to(:competition) }
	end

	context "validations" do
		it "requires a competition" do
	  		expect(season).to validate_presence_of(:competition)
	  	end
	end

	context '#create_game_weeks' do
		it "should create game_weeks for a season" do
			season.create_game_weeks
			game_weeks = season.game_weeks
			expect(game_weeks.count).to eq(season.competition.game_weeks_per_season)
		end
	end
end