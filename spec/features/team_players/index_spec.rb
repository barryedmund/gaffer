require 'spec_helper'

describe "Viewing team players" do
	let!(:team) {Team.create(title: "FC United")}
	it "displays no team players when a team is empty" do
		visit "/teams"
		within "#team_#{team.id}" do
			click_link "View team players"
		end
		expect(page).to have_content("TeamPlayers#index")
	end
end