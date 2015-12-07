require 'spec_helper'

describe Game do

	let!(:league_1){ League.create(:id => 1, :name => "League 1", :user_id => 1) }
	let!(:league_2){ League.create(:id => 2, :name => "League 2", :user_id => 1) }

	let!(:team_1){ Team.create(:id => 1, :title => "Team 1", :league => league_1, :user_id => 1) }
	let!(:team_2){ Team.create(:id => 2, :title => "Team 2", :league => league_1, :user_id => 2) }
	let!(:team_3){ Team.create(:id => 3, :title => "Team 3", :league => league_2, :user_id => 3) }
	let!(:team_4){ Team.create(:id => 4, :title => "Team 4", :league => league_1, :user_id => 4) }
	
	let!(:game_week){ create(:game_week) }
	
	let!(:game){ Game.create(:home_team => team_1, :away_team => team_2, :game_week => game_week) }
	let!(:invalid_game_1){ Game.create(:home_team => team_1, :away_team => team_3, :game_week => game_week) }
	let!(:invalid_game_2){ Game.create(:home_team => team_1, :away_team => team_1, :game_week => game_week) }
	let!(:invalid_game_3){ Game.create(:home_team => team_4, :away_team => team_1, :game_week => game_week) }

	context "relationships" do
		it {should belong_to(:home_team)}
		it {should belong_to(:away_team)}
		it {should belong_to(:game_week)}
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
	  	it "requires that the teams are in the same league" do
	  		expect(invalid_game_1).to_not be_valid
	  	end
	  	it "requires that home and away team are different" do
	  		expect(invalid_game_2).to_not be_valid
	  	end
	  	it "requires that a Team only plays once per GameWeek" do
	  		expect(invalid_game_3).to_not be_valid
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
