require 'spec_helper'

describe GameRound do
	let!(:game_round){ create(:game_round) }

	context "relationships" do
		it {should belong_to(:season)}
		it {should belong_to(:league)}
		it {should have_many(:games)}
	end	
end
