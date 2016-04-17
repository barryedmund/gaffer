require 'spec_helper'

describe PlayerGameWeeksController do
	let!(:player) { create(:player) }
	let!(:user) { create(:user) }
  let!(:season) { create(:season) }
  let!(:league) { create(:league) }
  let!(:home_team) { Team.create(id: 1, title: "Home Team", league: league) }
  let!(:away_team) { Team.create(id: 2, title: "Away Team", league: league, user: user) }
  let!(:league_season) { LeagueSeason.create(season: season, league: league) }
  let!(:game_week) { league_season.game_weeks.first }
	let!(:current_game_week) { GameWeek.get_current_game_week }

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
