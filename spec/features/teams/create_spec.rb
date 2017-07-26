require 'spec_helper'

describe "Creating teams" do
	let!(:user) { create(:user) }
	let!(:user_2) { create(:user) }
	let!(:user_3) { create(:user) }
  let!(:season) { create(:season, starts_at: Date.today - 365.days, ends_at: Date.today - 1.days) }
  let!(:season_2) { create(:season) }
  let!(:league) { create(:league, competition: season_2.competition) }
  let!(:home_team) { Team.create(id: 1, title: "Home Team", league: league, user: user_2) }
  let!(:away_team) { Team.create(id: 2, title: "Away Team", league: league, user: user) }
  let!(:league_season) { create(:league_season, season: season, league: league) }
	

	def create_team(options={})
		options[:title] ||= "My team"
		visit "/"
		visit "leagues/#{league.id}"
		click_link "Add Team"
		expect(page).to have_content("#{league.name} new team")
		fill_in :team_title, with: options[:title]
		fill_in :team_stadium_attributes_name, with: "My Stadium"
		click_button "Create Team"
	end

	before do
		sign_in user_3, password: "gaffer123"
	end

	it "redirects to the Dashboard page on success" do
		create_team
		expect(page).to have_content("Added team to league")
	end

	it "displays an error when the team has no title" do
		expect(Team.count).to eq(2)
		create_team title: ""
		expect(page).to have_content("error")
		expect(Team.count).to eq(2)
	end

	it "displays an error when the team has a title less than three characters" do
		expect(Team.count).to eq(2)
		create_team title: "FC"
		expect(page).to have_content("error")
		expect(Team.count).to eq(2)
	end

	it "doesn't allow more than 20 teams" do
		ActiveRecord::Base.transaction do
  			21.times do |i|
  				temp_user = User.create(:first_name => "Barry #{i}", :last_name => "Wallace", :email => "yo#{i}@me.com", :password => "yoyoyoyi", :password_confirmation => "yoyoyoyi")
  				Team.create(:league_id => league.id, :user => temp_user, :title => "Teamy")
  			end
		end
		visit "/"
		visit "leagues/#{league.id}"
		expect(page).to_not have_content("Barry 20 Wallace")
	end

	it "requires a unique User & League combo" do
		visit "/"
		visit "leagues/#{league.id}"
		click_link "Add Team"
		expect(page).to have_content("#{league.name} new team")
		fill_in :team_title, with: "Team One"
		click_button "Create Team"

		expect(page).to_not have_content("Add Team")
	end
end
