require 'spec_helper'

describe "Listing teams" do
	let!(:team) { create(:team) }

	it "requires login" do
		visit "leagues/#{team.league_id}/teams"
		expect(page).to have_content("Please log in or create an account before continuing.")
	end
end