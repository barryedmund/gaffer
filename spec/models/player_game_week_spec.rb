require 'spec_helper'

describe PlayerGameWeek do
  let!(:user) { create(:user) }
  let!(:season) { create(:season) }
  let!(:league) { create(:league) }
  let!(:home_team) { Team.create(id: 1, title: "Home Team", league: league) }
  let!(:away_team) { Team.create(id: 2, title: "Away Team", league: league, user: user) }
  let!(:league_season) { LeagueSeason.create(season: season, league: league) }
  let!(:game_week) { GameWeek.create(starts_at: Date.today + 100, ends_at: Date.today + 107, season: season) }
  let!(:player) { create(:player) }
	let!(:player_game_week_1) { PlayerGameWeek.create(player: player, game_week: game_week, minutes_played: 90) }

	context "relationships" do
  		it { should belong_to(:player) } 		
  		it { should belong_to(:game_week) }
  		it { should have_many(:player_lineups) }
  	end
  	
  	context "validations" do
	  	it "requires a Player ID" do
	  		expect(player_game_week_1).to validate_presence_of(:player_id)
	  	end

	  	it "requires a GameWeek ID" do
	  		expect(player_game_week_1).to validate_presence_of(:game_week_id)
	  	end

	  	it "requires a unique Player & GameWeek combo" do
			 should validate_uniqueness_of(:game_week_id).scoped_to(:player_id)
	  	end

      it "requires minutes played" do
        expect(player_game_week_1).to validate_presence_of(:minutes_played)
      end

      it "requires goals scored" do
        expect(player_game_week_1).to validate_presence_of(:goals)
      end
	end
end
