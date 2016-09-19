require 'spec_helper'

describe "Editing teams" do
	let!(:user) { create(:user) }
	let!(:competition) { create(:competition) }
  let!(:season) { create(:season, competition: competition) }
  let!(:league) { create(:league, competition: competition) }
	let!(:team) { create(:team, league: league, user: user) }
	let!(:stadium) { create(:stadium, team: team) }

	def update_team(options={})
		options[:title] ||= "My team"
		team = options[:team]
		visit "leagues/#{team.league_id}"
		click_link "#{team.title}"
		click_link "Edit team"
		fill_in :team_title, with: options[:title]
		click_button "Update Team"
	end

	before do
		sign_in team.user, password: "gaffer123"
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
