require 'spec_helper'

describe PlayerLineup do
	let!(:season) { create(:season) }
  let!(:game_week) { season.game_weeks.first }
  let!(:player) { create(:player) }
	let!(:player_game_week) { PlayerGameWeek.create(player: player, game_week: game_week, minutes_played: 90) }
	let!(:team) { create(:team) }
	let!(:squad_position) { create(:squad_position) }
	let!(:player_lineup) { PlayerLineup.create(team: team, player_game_week: player_game_week, squad_position: squad_position) }

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
