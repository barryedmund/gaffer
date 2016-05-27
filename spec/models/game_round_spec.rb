require 'spec_helper'

describe GameRound do
	let!(:user) { create(:user) }
  let!(:season) { create(:season) }
  let!(:league) { create(:league) }
  let!(:home_team) { Team.create(id: 1, title: "Home Team", league: league) }
  let!(:away_team) { Team.create(id: 2, title: "Away Team", league: league, user: user) }
  let!(:league_season) { LeagueSeason.create(season: season, league: league) }
  let!(:game_week) { GameWeek.create(starts_at: Date.today + 100, ends_at: Date.today + 107, season: season) }
  let!(:game_round) { GameRound.create(game_round_number: 1, league_season: league_season) }

	context "relationships" do
    it {should belong_to(:league_season)}
		it {should have_many(:games)}
	end	
end
