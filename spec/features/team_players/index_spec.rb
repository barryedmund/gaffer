require 'spec_helper'

describe "Viewing team players" do
	let(:user) { team.user }
	let!(:team) { create(:team) }
	before { sign_in user, password: "gaffer123" }

	it "displays the title of the team" do
		visit_team_players(team)
		within("#teamTitleHeader") do
			expect(page).to have_content(team.title)
		end
	end

	it "displays no team players when a team is empty" do
		visit_team_players(team)
		expect(page.all("ul.team_players li").size).to eq(0)
	end

	it "displays team players id when a team has team players" do
		team.team_players.create
		team.team_players.create
		visit_team_players(team)
		expect(page.all("ul.squad_players li").size).to eq(2)
	end
end