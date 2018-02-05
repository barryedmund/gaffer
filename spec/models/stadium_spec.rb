require 'spec_helper'

describe Stadium do
  let!(:team_1) { create(:team) }
  let!(:stadium) { create(:stadium, team: team_1) }

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
  end
end
