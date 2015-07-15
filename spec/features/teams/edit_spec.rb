require 'spec_helper'

describe "Editing teams" do
	let!(:team) { Team.create(title: "Fantasy Playas") }

	def update_team(options={})
		options[:title] ||= "My team"
		
		team = options[:team]

		visit "/teams"
		within "#team_#{team.id}" do
			click_link "Edit"
		end

		fill_in "Title", with: options[:title]
		click_button "Update Team"
	end

	it "updates a team successfully with correct information" do
		update_team team: team, title: "New Title"

		team.reload

		expect(page).to have_content("Team was successfully updated.")
		expect(team.title).to eq("New Title")
	end

	it "displays an error with no title" do
		update_team team: team, title: ""		
		expect(page).to have_content("error")
	end

	it "displays an error with too short a title" do
		update_team team: team, title: "FC"		
		expect(page).to have_content("error")
	end

end