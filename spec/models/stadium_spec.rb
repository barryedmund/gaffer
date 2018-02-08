require 'spec_helper'

describe Stadium do
  let!(:team_1) { create(:team) }
  let!(:team_2) { create(:team) }
  let!(:stadium) { create(:stadium, team: team_1) }
  let!(:big_stadium) { create(:stadium, team: team_2, capacity: 2000000) }

  context "relationships" do
    it { should belong_to(:team) }
  end

  context "validations" do
    it "requires a name" do
      expect(stadium).to validate_presence_of(:name)
    end

    it "requires a capacity" do
      expect(stadium).to validate_presence_of(:capacity)
    end

    it "requires a unique team" do
      expect(stadium).to validate_uniqueness_of(:team)
    end

    it "can't be bigger than the max allowed" do
      expect(big_stadium).to_not be_valid
    end
  end
end
