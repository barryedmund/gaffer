require 'spec_helper'

describe SquadPosition do
	context "relationships" do
    	it { should have_many(:team_players) }
      it { should have_many(:player_lineups) }
  	end

  	context "validations" do
  		let(:squad_position) {
  			SquadPosition.new()
  		}

	  	it "requires a short_name" do
	  		expect(squad_position).to validate_presence_of(:short_name)
	  	end
  	end
end
