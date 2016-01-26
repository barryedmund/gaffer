require 'spec_helper'

describe PlayerLineup do
	let!(:player_lineup){ create(:player_lineup) }

	context "relationships" do
		it {should belong_to(:player_game_week)}
		it {should belong_to(:team)}
		it {should belong_to(:squad_position)}
	end

	context "validations" do
		it "requires a player_game_week ID" do
	  	expect(player_lineup).to validate_presence_of(:player_game_week_id)
	  end

	  it "requires a team ID" do
	  	expect(player_lineup).to validate_presence_of(:team_id)
	  end

	  it "requires a squad_position ID" do
	  	expect(player_lineup).to validate_presence_of(:squad_position_id)
	  end
	end
end
