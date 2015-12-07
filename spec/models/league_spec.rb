require 'spec_helper'

describe League do

	let!(:league){create(:league)}

	context "relationships" do
	  	it {should belong_to(:competition)}
	  	it {should belong_to(:user)}
	  	it {should have_many(:teams)}
	end

	context "validations" do
		it "requires a competition" do
	  		expect(league).to validate_presence_of(:competition)
	  	end
	end
end