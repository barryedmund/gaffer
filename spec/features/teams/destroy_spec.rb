require 'spec_helper'

describe "Deleting teams" do
	let(:user) { team.user }
	let!(:team) { create(:team) }

	before do
		sign_in user, password: "gaffer123"
	end
end