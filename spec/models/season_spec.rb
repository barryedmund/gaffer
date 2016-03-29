require 'spec_helper'

describe Season do

	let!(:season){ create(:season) }

	context "relationships" do
	  it { should have_many(:game_weeks) }
	  it { should have_many(:league_seasons) }
	  it { should belong_to(:competition) }
	end

	context "validations" do
		it "requires a competition" do
	  		expect(season).to validate_presence_of(:competition)
	  	end
	end

	context '#create_game_weeks' do
		it "should create game_weeks for a season" do
			expect(GameWeek.all.count).to eq(season.competition.game_weeks_per_season)
		end
	end
end
