require 'spec_helper'

describe GameRound do
	let!(:game_round){ create(:game_round) }

	context "relationships" do
    it {should belong_to(:league_season)}
		it {should have_many(:games)}
	end	
end
