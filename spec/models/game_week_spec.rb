require 'spec_helper'

describe GameWeek do
  let!(:game_week){ GameWeek.create(id: 1, starts_at: Date.today - 2, ends_at: Date.today + 2, season_id: 1, game_week_number: 1) }
  let!(:game_week_2){ GameWeek.create(id: 2, starts_at: Date.today, ends_at: Date.today + 4, season_id: 1, game_week_number: 2) }
  let!(:game_week_negative_game_week_number){ GameWeek.create(id: 3, starts_at: Date.today + 7, ends_at: Date.today + 14, season_id: 1, game_week_number: -1) }
  let!(:game_week_duplicate_game_week_number){ GameWeek.create(id: 4, starts_at: Date.today + 15, ends_at: Date.today + 22, season_id: 1, game_week_number: 1) }

	context "relationships" do
      it {should belong_to(:season)}
  		it {should have_many(:player_game_weeks)}
      it {should have_many(:games)}
  	end

  	context "validations" do
	  	it "requires a start date" do
	  		expect(game_week).to validate_presence_of(:starts_at)
	  	end

	  	it "requires a end date" do
	  	  expect(game_week).to validate_presence_of(:ends_at)
	  	end

	  	it "requires no overlap of dates" do
        expect(game_week_2).to_not be_valid
	  	end

      it "requires a game_week_number" do
        expect(game_week).to validate_presence_of(:game_week_number)
      end

      it "requires a game_week_number greater than 0" do
        expect(game_week_negative_game_week_number).to_not be_valid
      end

      it "requires a game_week_number that in unique to the season" do
        expect(game_week_duplicate_game_week_number).to_not be_valid
      end
  	end
end
