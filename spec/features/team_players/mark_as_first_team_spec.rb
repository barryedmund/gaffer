require 'spec_helper'

describe "Marking a team player as first team" do
	let(:user) { team.user }
	let!(:team) { create(:team) }
	let!(:player) { create(:player) }
	let!(:team_player) { team.team_players.create(player_id: player.id) }
	
	before { sign_in user, password: "gaffer123" }
	
	it "is successful when marking a single team player as first team" do
		expect(team_player.first_team).to eq(false)
		visit_team_players team
		within dom_id_for(team_player) do
			click_link "Add to first team"
		end
		team_player.reload
		expect(team_player.first_team).to eq(true)
	end

	it "is successful when removing a single team player from the first team" do
		expect(team_player.first_team).to eq(false)
		visit_team_players team
		within dom_id_for(team_player) do
			click_link "Add to first team"
		end
		team_player.reload
		expect(team_player.first_team).to eq(true)

		within dom_id_for(team_player) do
			click_link "Remove from first team"
		end
		team_player.reload
		expect(team_player.first_team).to eq(false)
	end
end