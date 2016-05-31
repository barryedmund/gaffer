require 'spec_helper'

describe LeagueInvite do
  let!(:league_invite) { create(:league_invite) }

  context "relationships" do
    it { should belong_to(:league) }
  end

  context "validations" do
    it "requires a league" do
      expect(league_invite).to validate_presence_of(:league)
    end

    it "requires an email" do
      expect(league_invite).to validate_presence_of(:email)
    end

    it "requires a unique email in the league" do
      expect(league_invite).to validate_uniqueness_of(:email).scoped_to(:league_id)
    end
  end
end
