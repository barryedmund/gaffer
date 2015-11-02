require 'spec_helper'

describe "Viewing team players" do
	let(:user) { team.user }
	let!(:team) { create(:team) }
	let!(:player) { create(:player) }
	let!(:squad_position) { create(:squad_position) }
	before { sign_in user, password: "gaffer123" }

	it "displays the title of the team" do
		visit_team_players(team)
		within(".main_header") do
			expect(page).to have_content(team.title)
		end
	end

	it "displays no team players when a team is empty" do
		visit_team_players(team)
		expect(page.all("ul.team_players li").size).to eq(0)
	end

	it "displays team players id when a team has team players" do
		visit_team_players(team)
		click_link "add player"
		select("Paul Pogba", :from => "team_player_player_id")
		click_button "Add player to squad"
		expect(page.all("ul.squad_players li").size).to eq(1)
	end
end