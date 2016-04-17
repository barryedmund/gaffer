require 'spec_helper'

describe Season do

	let!(:season){ create(:season) }

	context "relationships" do
	  it { should have_many(:league_seasons) }
	  it { should belong_to(:competition) }
	end

	context "validations" do
		it "requires a competition" do
	  		expect(season).to validate_presence_of(:competition)
	  	end
	end
end
