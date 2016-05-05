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

		it "requires a playing position" do
			expect(player).to validate_presence_of(:playing_position)
		end

		it "requires a pl_player_code" do
			expect(player).to validate_presence_of(:pl_player_code)
		end
	end

	context "relationships" do
	  it { should have_many(:team_players) }
	  it { should have_many(:player_game_weeks) }
	end
end
