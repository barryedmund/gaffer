require 'spec_helper'

describe Game do

	let!(:league_1){ League.create(:id => 1, :name => "League 1", :user_id => 1) }
	let!(:league_2){ League.create(:id => 2, :name => "League 2", :user_id => 1) }

	let!(:team_1){ Team.create(:id => 1, :title => "Team 1", :league => league_1, :user_id => 1) }
	let!(:team_2){ Team.create(:id => 2, :title => "Team 2", :league => league_1, :user_id => 2) }
	let!(:team_3){ Team.create(:id => 3, :title => "Team 3", :league => league_2, :user_id => 3) }
	let!(:team_4){ Team.create(:id => 4, :title => "Team 4", :league => league_1, :user_id => 4) }
	let!(:team_5){ Team.create(:id => 5, :title => "Team 5", :league => league_1, :user_id => 5) }
	let!(:team_6){ Team.create(:id => 6, :title => "Team 6", :league => league_1, :user_id => 6) }
	
	let!(:game_week){ create(:game_week) }
	let!(:game_week_2){ GameWeek.create(:id => 2, :starts_at => Date.today - 7, :ends_at => Date.today, :season => season) }

	let!(:game_round){ create(:game_round) }
	let!(:season){ create(:season) }
	
	let!(:game){ Game.create(:home_team => team_1, :away_team => team_2, :game_week => game_week, :game_round => game_round, :league => league_1) }
	let!(:invalid_game_1){ Game.create(:home_team => team_1, :away_team => team_3, :game_week => game_week, :game_round => game_round, :league => league_1) }
	let!(:invalid_game_2){ Game.create(:home_team => team_1, :away_team => team_1, :game_week => game_week, :game_round => game_round, :league => league_1) }
	let!(:invalid_game_3){ Game.create(:home_team => team_4, :away_team => team_1, :game_week => game_week, :game_round => game_round, :league => league_1) }
	let!(:invalid_game_4){ Game.create(:home_team => team_5, :away_team => team_6, :game_week => game_week, :game_round => game_round, :league => league_2) }
	let!(:invalid_game_5){ Game.create(:home_team => team_1, :away_team => team_2, :game_week => game_week_2, :game_round => game_round, :league => league_1) }

	context "relationships" do
		it {should belong_to(:home_team)}
		it {should belong_to(:away_team)}
		it {should belong_to(:game_week)}
		it {should belong_to(:game_round)}
		it {should belong_to(:league)}
	end

	context "validations" do
		it "requires a home team" do
  		expect(game).to validate_presence_of(:home_team)
  	end
  	it "requires an away team" do
  		expect(game).to validate_presence_of(:away_team)
  	end
  	it "requires a game week" do
  		expect(game).to validate_presence_of(:game_week)
  	end
  	it "requires a game round" do
  		expect(game).to validate_presence_of(:game_round)
  	end
  	it "requires a league" do
  		expect(game).to validate_presence_of(:league)
  	end
  	it "requires that the teams are in the same league" do
  		expect(invalid_game_1).to_not be_valid
  	end
  	it "requires that home and away team are different" do
  		expect(invalid_game_2).to_not be_valid
  	end
  	it "requires that a Team only plays once per GameWeek" do
  		expect(invalid_game_3).to_not be_valid
  	end
  	it "requires that the League is the same as the Teams' League" do
  		expect(invalid_game_4).to_not be_valid
  	end
  	it "requires that the same Teams don't play each other twice in the same venue in the same GameRound" do
  		expect(invalid_game_5).to_not be_valid
  	end
	end

	describe "#match_up" do
	    it "returns both teams in the Game" do
	      match_up_string = game.match_up
	      expect(match_up_string).to include(game.home_team.title)
	      expect(match_up_string).to include(game.away_team.title)
	    end
	end
end
