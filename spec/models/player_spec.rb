require 'spec_helper'

describe Player do
	let!(:player) { create(:player) }

	context "validations" do
		it "requires a first name" do
			expect(player).to validate_presence_of(:first_name)
		end

		it "requires a last name" do
			expect(player).to validate_presence_of(:last_name)
		end
	end

	context "relationships" do
	  it { should have_many(:team_players) }
	  it { should have_many(:player_game_weeks) }
	end
end
