require 'spec_helper'

describe "Listing teams" do
	it "requires login" do
		visit "/teams"
		expect(page).to have_content("You must be logged in.")
	end
end