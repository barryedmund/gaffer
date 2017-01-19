require 'spec_helper'

describe Auction do

  let!(:auction){ create(:auction) }

  context "relationships" do
    it {should belong_to(:team_player)}
  end

  context "validations" do
    it "requires a minimum bid" do
      expect(auction).to validate_presence_of(:minimum_bid)
    end
    it "requires a team player" do
      expect(auction).to validate_presence_of(:team_player_id)
    end
    it "requires a is_voluntary" do
      expect(auction).to validate_presence_of(:is_voluntary)
    end
    it "requires a is_active" do
      expect(auction).to validate_presence_of(:is_active)
    end
  end
end
