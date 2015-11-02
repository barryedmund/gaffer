require 'spec_helper'

describe "Adding team players" do
	let(:user) { team.user }
	let!(:team) { create(:team) }
	let!(:player) { create(:player) }
	let!(:squad_position) { create(:squad_position) }
	before { sign_in user, password: "gaffer123" }

	it "is successful with valid content" do
		visit_team_players(team)
		click_link "add player"
		select("Paul Pogba", :from => "team_player_player_id")
		click_button "Add player to squad"
		expect(page).to have_content("Added team player")
		within("ul.squad_players") do
			expect(page).to have_content("Paul Pogba")
		end
	end

	it "adds squad position SUB to newly added players" do
		visit_team_players(team)
		click_link "add player"
		select("Paul Pogba", :from => "team_player_player_id")
		click_button "Add player to squad"
		expect(page).to have_content("Added team player")
		team.reload
		within("ul.squad_players") do
			expect(page).to have_content("Paul Pogba")
		end
	end
end