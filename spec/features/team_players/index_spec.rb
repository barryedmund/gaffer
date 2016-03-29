require 'spec_helper'

describe "Viewing team players" do
	let(:user) { team.user }
	let!(:team) { create(:team) }
	let!(:player) { create(:player) }
	let!(:squad_position_1) { SquadPosition.create(short_name: "GK") }
	let!(:squad_position_2) { SquadPosition.create(short_name: "SUB") }
	let!(:squad_position_3) { SquadPosition.create(short_name: "DF") }
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
		fill_in "team_player_contracts_attributes_0_weekly_salary_cents", :with => 1000000
		fill_in "team_player_contracts_attributes_0_ends_at", :with => Date.today + 500
		click_button "Add player to squad"
		expect(page.all("ul.squad_players li").size).to eq(1)
	end
end
