require 'spec_helper'

describe "Removing team players" do
	let(:user) { team.user }
	let!(:team) { create(:team) }
	let!(:player) { create(:player) }
	let!(:squad_position_1) { SquadPosition.create(short_name: "GK") }
	let!(:squad_position_2) { SquadPosition.create(short_name: "SUB") }
	let!(:squad_position_3) { SquadPosition.create(short_name: "DF") }
	let!(:team_player) { team.team_players.create(player_id: player.id, squad_position_id: squad_position_2.id) }
	let!(:contract) {Contract.create(team: team, team_player: team_player, weekly_salary_cents: 1000000, starts_at: Date.today - 1, ends_at: Date.today + 1)}
	
	before { sign_in user, password: "gaffer123" }

	it "is successful" do
		visit_team_players(team)
		within "#team_player_#{team_player.id}" do
			click_button "Remove from squad."
		end
		expect(page).to have_content("Team player was removed successfully.")
	end
end
