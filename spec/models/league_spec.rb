require 'spec_helper'

describe League do

	let!(:league){create(:league)}
	let!(:team_1){ Team.create(:id => 1, :title => "Team 1", :league => league, :user_id => 1) }
	let!(:team_2){ Team.create(:id => 2, :title => "Team 2", :league => league, :user_id => 2) }
	let!(:team_3){ Team.create(:id => 3, :title => "Team 3", :league => league, :user_id => 3) }
	let!(:team_4){ Team.create(:id => 4, :title => "Team 4", :league => league, :user_id => 4) }

	context "relationships" do
	  	it {should belong_to(:competition)}
	  	it {should belong_to(:user)}
	  	it {should have_many(:teams)}
	  	it {should have_many(:league_seasons)}
	end

	context "validations" do
		it "requires a competition" do
	  	expect(league).to validate_presence_of(:competition)
	  end
	end
end
