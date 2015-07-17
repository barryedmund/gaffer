require 'spec_helper'

describe "Deleting teams" do
	let!(:team) { Team.create(title: "Fantasy Playas") }

	it "is successful when clicking the destroy link" do
		visit "/teams"
		within "#team_#{team.id}" do
			click_link "Destroy"
		end
		expect(page).to_not have_content(team.title)
		expect(Team.count).to eq(0)
	end
end