require 'spec_helper'

describe "Moving team players between first team and bench" do
	let!(:competition) { create(:competition) }
  let!(:season) { create(:season, competition: competition) }
  let!(:league) { create(:league, competition: competition) }
	let!(:team) { create(:team, league: league, user: league.user) }
	let!(:team_player) { create(:team_player, :with_contract, team: team) }
	let!(:midfielder_squad_position) { create(:midfielder_squad_position) }
	let!(:stadium) { create(:stadium, team: team) }
	before { sign_in league.user, password: "gaffer123" }
	
	it "is successful when marking a single team player as first team" do
		visit_team_players team
		within dom_id_for(team_player) do
			click_button "Add"
		end
		team_player.reload
		expect(team_player.first_team).to eq(true)
		expect(team_player.squad_position.short_name).to_not eq("SUB")
	end

	it "isn't possible when there are already 11 first team players" do
		FactoryGirl.create_list(:team_player, 11, :with_contract, first_team: true, team: team)
		twelfth_team_player = FactoryGirl.create(:team_player, :with_contract, first_team: false, team: team)
		visit_team_players team
		within dom_id_for(twelfth_team_player) do
			expect(page).to_not have_selector("input[type=submit][value='Add to first team']")
		end
	end

	it "isn't possible to add player when player's game_week_deadline_at has passed" do
		visit_team_players team
		team_player.player.update_attributes(game_week_deadline_at: Time.now - 2.hours)
		within dom_id_for(team_player) do
			click_button "Add"
		end
		expect(page).to_not have_content("Added to first team.")
		expect(page).to have_content("That player's deadline has passed for this gameweek.")
		team_player.reload
		expect(team_player.first_team).to eq(false)
		expect(team_player.squad_position.short_name).to eq("SUB")
	end

	it "isn't possible to drop player when player's game_week_deadline_at has passed" do
		visit_team_players team
		within dom_id_for(team_player) do
			click_button "Add"
		end
		team_player.player.update_attributes(game_week_deadline_at: Time.now - 2.hours)
		within dom_id_for(team_player) do
			click_button "Drop"
		end
		expect(page).to_not have_content("Removed from first team.")
		expect(page).to have_content("That player's deadline has passed for this gameweek.")
		team_player.reload
		expect(team_player.first_team).to eq(true)
		expect(team_player.squad_position.short_name).to_not eq("SUB")
	end

	it "is successful when removing a single team player from the first team" do
		visit_team_players team
		within dom_id_for(team_player) do
			click_button "Add"
		end
		within dom_id_for(team_player) do
			click_button "Drop"
		end
		team_player.reload
		expect(team_player.first_team).to eq(false)
		expect(team_player.squad_position.short_name).to eq("SUB")
	end
end
