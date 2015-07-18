require 'spec_helper'

describe "Adding team players" do
	let!(:team) {Team.create(title: "FC United")}

	def visit_team_players(this_team)
		visit "/teams"
		within "#team_#{this_team.id}" do
			click_link "View team players"
		end
	end

	it "is successful with valid content" do
		visit_team_players(team)
		click_link "Add player to team"
		click_button "Confirm"
		expect(page).to have_content("Added team player")
		within("ul.team_players") do
			expect(page).to have_content("1")
		end
	end
end