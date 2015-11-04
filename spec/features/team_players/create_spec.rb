require 'spec_helper'

describe "Adding team players" do
	let(:user) { team.user }
	let!(:team) { create(:team) }
	let!(:league_1) { League.create(user: user, name: "Second League") }
	let!(:team_1) { Team.create(title: "Second League Team", user: user, league: league_1) }
	let!(:player) { create(:player) }
	let!(:squad_position_1) { SquadPosition.create(short_name: "GK") }
	let!(:squad_position_2) { SquadPosition.create(short_name: "SUB") }
	let!(:squad_position_3) { SquadPosition.create(short_name: "DF") }
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

	it "is successful when a TeamPlayer has already been created from the same Player in a different League" do
		visit_team_players(team)
		click_link "add player"
		select("Paul Pogba", :from => "team_player_player_id")
		click_button "Add player to squad"
		expect(page).to have_content("Added team player")
		within("ul.squad_players") do
			expect(page).to have_content("Paul Pogba")
		end
		visit "/"
		visit_team_players(team_1)
		click_link "add player"
		select("Paul Pogba", :from => "team_player_player_id")
		click_button "Add player to squad"
		expect(page).to have_content("Added team player")
		within("ul.squad_players") do
			expect(page).to have_content("Paul Pogba")
		end
	end
end