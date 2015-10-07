require 'spec_helper'

describe "Removing team players" do
	let(:user) { team.user }
	let!(:team) { create(:team) }
	let!(:player) { create(:player) }
	let!(:team_player) { team.team_players.create(player_id: player.id) }
	
	before { sign_in user, password: "gaffer123" }

	it "is successful" do
		visit_team_players(team)
		within "#team_player_#{team_player.id}" do
			click_link "Remove"
		end
		expect(page).to have_content("Team player was removed successfully.")
	end
end