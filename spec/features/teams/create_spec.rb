require 'spec_helper'

describe "Creating teams" do
	let(:user) { create(:user) }
	let!(:league) { create(:league) }

	def create_team(options={})
		options[:title] ||= "My team"
		visit "/"
		visit "leagues/#{league.id}"
		click_link "Add Team"
		expect(page).to have_content("New team")

		fill_in "Title", with: options[:title]
		click_button "Create Team"
	end

	before do
		sign_in user, password: "gaffer123"
	end

	it "redirects to the Dashboard page on success" do
		create_team
		expect(page).to have_content("Added team to league")
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
		ActiveRecord::Base.transaction do
  			21.times do |i|
  				temp_user = User.create(:first_name => "Barry #{i}", :last_name => "Wallace", :email => "yo#{i}@me.com", :password => "yoyoyoyi", :password_confirmation => "yoyoyoyi")
  				Team.create(:league_id => 1, :user => temp_user, :title => "Teamy")
  			end
		end
		visit "/"
		visit "leagues/1"
		expect(page).to_not have_content("Barry 20 Wallace")
	end

	it "requires a unique User & League combo" do
		visit "/"
		visit "leagues/#{league.id}"
		click_link "Add Team"
		expect(page).to have_content("New team")
		fill_in "Title", with: "Team One"
		click_button "Create Team"

		expect(page).to_not have_content("Add Team")
	end
end