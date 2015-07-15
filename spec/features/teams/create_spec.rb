require 'spec_helper'

describe "Creating teams" do
	def create_team(options={})
		options[:title] ||= "My team"

		visit "/teams"
		click_link "New Team"
		expect(page).to have_content("New team")

		fill_in "Title", with: options[:title]
		click_button "Create Team"
	end

	it "redirects to the team index page on success" do
		create_team
		expect(page).to have_content("My team")
	end

	it "displays an error when the team has no title" do
		expect(Team.count).to eq(0)
		create_team title: ""
		expect(page).to have_content("error")
		expect(Team.count).to eq(0)
	end

	it "displays an error when the team has a title less than three characters" do
		expect(Team.count).to eq(0)
		create_team title: "FC"
		expect(page).to have_content("error")
		expect(Team.count).to eq(0)
	end
end