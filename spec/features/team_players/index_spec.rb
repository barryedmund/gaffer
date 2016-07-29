require 'spec_helper'

describe "Viewing team players" do
	let(:user) { team.user }
	let!(:team) { create(:team) }
	let!(:player) { create(:player) }
	let!(:squad_position_1) { SquadPosition.create(short_name: "GK") }
	let!(:squad_position_2) { SquadPosition.create(short_name: "SUB") }
	let!(:squad_position_3) { SquadPosition.create(short_name: "DF") }
	let!(:squad_position_midfielder) { create(:midfielder_squad_position) }
	let!(:stadium) { create(:stadium, team: team) }
	before { sign_in user, password: "gaffer123" }

	it "displays the title of the team" do
		visit_team_players(team)
		within(".mdl-card__title-text") do
			expect(page).to have_content(team.title)
		end
	end

	it "displays no team players when a team is empty" do
		visit_team_players(team)
		expect(page.all("ul.team_players li").size).to eq(0)
	end
end
