require 'spec_helper'

describe "Creating teams" do
	let(:user) { create(:user) }
	let!(:league) { create(:league) }

	def create_team(options={})
		options[:title] ||= "My team"
		visit "/"
		visit "leagues/#{league.id}/teams"
		click_link "New Team"
		expect(page).to have_content("New team")

		fill_in "Title", with: options[:title]
		click_button "Create Team"
	end

	before do
		sign_in user, password: "gaffer123"
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

	it "doesn't allow more than 20 teams" do
		21.times { create_team }
		expect(page).to have_content("error")
	end
end