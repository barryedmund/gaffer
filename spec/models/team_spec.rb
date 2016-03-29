require 'spec_helper'

describe Team do

	context "relationships" do
	  it { should have_many(:team_players) }
	  it { should belong_to(:user) }
	  it { should have_many(:player_lineups) }
    it { should have_many(:contracts) }
	end
end
