require 'spec_helper'

describe "Deleting teams" do
	let(:user) { team.user }
	let!(:team) { create(:team) }

	before do
		sign_in user, password: "gaffer123"
	end

	it "is successful when clicking the destroy link" do
		visit "/teams"
		within "#team_#{team.id}" do
			click_link "Destroy"
		end
		expect(page).to_not have_content(team.title)
		expect(Team.count).to eq(0)
	end
end