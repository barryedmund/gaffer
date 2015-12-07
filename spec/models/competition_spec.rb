require 'spec_helper'

describe Competition do

	let!(:competition){ create(:competition) }

	context "relationships" do
		it {should have_many(:seasons)}
		it {should have_many(:leagues)}
	end

	context "validations" do
		it "requires a country code" do
	  		expect(competition).to validate_presence_of(:country_code)
	  	end
	  	it "requires a description" do
	  		expect(competition).to validate_presence_of(:description)
	  	end
	  	it "requires rounds_per_season" do
	  		expect(competition).to validate_presence_of(:rounds_per_season)
	  	end
	end
end