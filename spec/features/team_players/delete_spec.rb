require 'spec_helper'

describe "Removing team players" do
	let(:user) { team.user }
	let!(:team) { create(:team) }
	let!(:player) { create(:player) }
	let!(:squad_position) { create(:squad_position) }
	let!(:team_player) { team.team_players.create(player_id: player.id, squad_position_id: squad_position.id) }
	
	before { sign_in user, password: "gaffer123" }

	it "is successful" do
		visit_team_players(team)
		within "#team_player_#{team_player.id}" do
			click_button "Remove from squad."
		end
		expect(page).to have_content("Team player was removed successfully.")
	end
end