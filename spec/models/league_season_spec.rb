require 'spec_helper'

describe LeagueSeason do
  let!(:competition) { Competition.create(country_code: "en", description: "Premier League", game_weeks_per_season: 38) }
  let!(:season) { Season.create(description: "2015/16", starts_at: "2015-08-01", ends_at: "2016-05-31", competition: competition) }
  let!(:league){ League.create(:id => 1, :name => "League 1", user_id: 1, competition: competition) }
  let!(:team_1){ Team.create(:id => 1, :title => "Team 1", league: league, :user_id => 1) }
  let!(:team_2){ Team.create(:id => 2, :title => "Team 2", league: league, :user_id => 2) }
  let!(:league_season) { LeagueSeason.create(season: season, league: league) }

  context "relationships" do
    it {should belong_to(:season)}
    it {should belong_to(:league)}
  end

  context '#create_game_weeks' do
    it "should create game_weeks for a season" do
      expect(GameWeek.all.count).to eq(season.competition.game_weeks_per_season)
    end
  end
end
