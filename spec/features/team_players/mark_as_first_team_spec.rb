require 'spec_helper'

describe "Marking a team player as first team" do
	let(:user) { team.user }
	let!(:team) { create(:team) }	
	let!(:squad_position) { SquadPosition.create(short_name: "GK") }
	let!(:squad_position_1) { SquadPosition.create(short_name: "SUB") }
	let!(:squad_position_2) { SquadPosition.create(short_name: "DF") }
	let!(:player) { create(:player) }
	let!(:player_1) { Player.create(first_name: "Thierry", last_name: "Henry") }
	let!(:player_3) { Player.create(first_name: "Joe", last_name: "Bloggs3") }
	let!(:player_4) { Player.create(first_name: "Joe", last_name: "Bloggs4") }
	let!(:player_5) { Player.create(first_name: "Joe", last_name: "Bloggs5") }
	let!(:player_6) { Player.create(first_name: "Joe", last_name: "Bloggs6") }
	let!(:player_7) { Player.create(first_name: "Joe", last_name: "Bloggs7") }
	let!(:player_8) { Player.create(first_name: "Joe", last_name: "Bloggs8") }
	let!(:player_9) { Player.create(first_name: "Joe", last_name: "Bloggs9") }
	let!(:player_10) { Player.create(first_name: "Joe", last_name: "Bloggs10") }
	let!(:player_11) { Player.create(first_name: "Joe", last_name: "Bloggs11") }
	let!(:player_12) { Player.create(first_name: "Joe", last_name: "Bloggs12") }
	let!(:team_player) { team.team_players.create(player_id: player.id, squad_position_id: squad_position.id) }
	let!(:team_player_1) {team.team_players.create(player_id: player_1.id, first_team: false, squad_position: squad_position_1)}
	let!(:team_player_3) { team.team_players.create(player_id: player_3.id, first_team: false, squad_position: squad_position_1)}
	let!(:team_player_4) { team.team_players.create(player_id: player_4.id, first_team: false, squad_position: squad_position_1)}
	let!(:team_player_5) { team.team_players.create(player_id: player_5.id, first_team: false, squad_position: squad_position_1)}
	let!(:team_player_6) { team.team_players.create(player_id: player_6.id, first_team: false, squad_position: squad_position_1)}
	let!(:team_player_7) { team.team_players.create(player_id: player_7.id, first_team: false, squad_position: squad_position_1)}
	let!(:team_player_8) { team.team_players.create(player_id: player_8.id, first_team: false, squad_position: squad_position_1)}
	let!(:team_player_9) { team.team_players.create(player_id: player_9.id, first_team: false, squad_position: squad_position_1)}
	let!(:team_player_10) { team.team_players.create(player_id: player_10.id, first_team: false, squad_position: squad_position_1)}
	let!(:team_player_11) { team.team_players.create(player_id: player_11.id, first_team: false, squad_position: squad_position_1)}
	let!(:team_player_12) { team.team_players.create(player_id: player_12.id, first_team: false, squad_position: squad_position_1)}

	before { sign_in user, password: "gaffer123" }

	it "is successful when marking a single team player as first team" do
		expect(team_player.first_team).to eq(false)
		visit_team_players team
		within dom_id_for(team_player) do
			select("GK", :from => "squad_position_team_player")
			click_button "Add to first team"
		end
		team_player.reload
		expect(team_player.first_team).to eq(true)
	end

	it "is successful & sets squad_position to something other thab SUB" do
		expect(team_player.first_team).to eq(false)
		visit_team_players team
		within dom_id_for(team_player) do
			select("GK", :from => "squad_position_team_player")
			click_button "Add to first team"
		end
		team_player.reload
		expect(team_player.squad_position.short_name).to_not eq("SUB")
	end

	it "isn't possible when there are already 11 first team players" do
		visit_team_players team
		within dom_id_for(team_player) do
			select("DF", :from => "squad_position_team_player")
			click_button "Add to first team"
		end
		within dom_id_for(team_player_1) do
			select("DF", :from => "squad_position_team_player")
			click_button "Add to first team"
		end
		within dom_id_for(team_player_3) do
			select("DF", :from => "squad_position_team_player")
			click_button "Add to first team"
		end
		within dom_id_for(team_player_4) do
			select("DF", :from => "squad_position_team_player")
			click_button "Add to first team"
		end
		within dom_id_for(team_player_5) do
			select("DF", :from => "squad_position_team_player")
			click_button "Add to first team"
		end
		within dom_id_for(team_player_6) do
			select("DF", :from => "squad_position_team_player")
			click_button "Add to first team"
		end
		within dom_id_for(team_player_7) do
			select("DF", :from => "squad_position_team_player")
			click_button "Add to first team"
		end
		within dom_id_for(team_player_8) do
			select("DF", :from => "squad_position_team_player")
			click_button "Add to first team"
		end
		within dom_id_for(team_player_9) do
			select("DF", :from => "squad_position_team_player")
			click_button "Add to first team"
		end
		within dom_id_for(team_player_10) do
			select("DF", :from => "squad_position_team_player")
			click_button "Add to first team"
		end
		within dom_id_for(team_player_11) do
			select("DF", :from => "squad_position_team_player")
			click_button "Add to first team"
		end
		within dom_id_for(team_player_12) do
			expect(page).to_not have_selector("input[type=submit][value='Add to first team']")
		end
	end
end

describe "Setting a team_player as not first_team" do
	let(:user) { team.user }
	let!(:team) { create(:team) }
	let!(:player_1) { Player.create(first_name: "Paul", last_name: "Pogba") }
	let!(:player_2) { Player.create(first_name: "Thierry", last_name: "Henry") }
	let!(:squad_position_1) { SquadPosition.create(short_name: "GK") }
	let!(:squad_position_2) { SquadPosition.create(short_name: "SUB") }
	let!(:team_player_1) { team.team_players.create(player_id: player_1.id, squad_position_id: squad_position_2.id) }
	let!(:team_player_2) { team.team_players.create(player_id: player_2.id, squad_position_id: squad_position_2.id) }

	before { sign_in user, password: "gaffer123" }

	it "is successful when removing a single team player from the first team" do
		expect(team_player_1.first_team).to eq(false)
		visit_team_players team
		within dom_id_for(team_player_1) do
			select("GK", :from => "squad_position_team_player")
			click_button "Add to first team"
		end
		team_player_1.reload
		expect(team_player_1.first_team).to eq(true)

		within dom_id_for(team_player_1) do
			click_button "Remove from first team"
		end
		team_player_1.reload
		expect(team_player_1.first_team).to eq(false)
	end

	it "is successful & sets squad_position to SUB" do
		expect(team_player_1.first_team).to eq(false)
		visit_team_players team
		within dom_id_for(team_player_1) do
			select("GK", :from => "squad_position_team_player")
			click_button "Add to first team"
		end
		team_player_1.reload
		expect(team_player_1.first_team).to eq(true)
		expect(team_player_1.squad_position.short_name).to_not eq("SUB")

		within dom_id_for(team_player_1) do
			click_button "Remove from first team"
		end
		team_player_1.reload
		expect(team_player_1.first_team).to eq(false)
		expect(team_player_1.squad_position.short_name).to eq("SUB")
	end
end