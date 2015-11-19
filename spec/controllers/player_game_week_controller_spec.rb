require 'spec_helper'

describe PlayerGameWeeksController do
	let!(:league) { create(:league) }
	let!(:team) { create(:team) }
	let!(:team_player) { create(:team_player) }
	let!(:player) { create(:player) }
	let!(:game_week) { create(:game_week) }
	let!(:current_game_week) { GameWeek.get_current_game_week }
	let(:valid_attributes) { {:player => player, :game_week => game_week } }
	let(:valid_session) { {} }

	describe "POST create" do
		describe "with valid params" do
  			it "creates a new PlayerGameWeek" do
    			expect { PlayerGameWeek.create(player_id: player.id, game_week_id: current_game_week.id) }.to change{ PlayerGameWeek.count }.by(1)
  			end

  			it "assigns a newly created player_game_week as @player_game_week" do
  				player_game_week = PlayerGameWeek.create(player_id: player.id, game_week_id: current_game_week.id)
  				player_game_week.should be_a(PlayerGameWeek)
        		player_game_week.should be_persisted
  			end
  		end
    end
end