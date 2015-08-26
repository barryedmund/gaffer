require 'spec_helper'

describe "Adding team players" do
	let(:user) { team.user }
	let!(:team) { create(:team) }
	before { sign_in user, password: "gaffer123" }

	it "is successful with valid content" do
		visit_team_players(team)
		click_link "Add player to team"
		click_button "Confirm"
		expect(page).to have_content("Added team player")
		within("ul.squad_players") do
			expect(page).to have_content("1")
		end
	end
end