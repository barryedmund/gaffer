require 'spec_helper'

describe LeagueInvite do
  let!(:league_invite) { create(:league_invite) }
  let!(:league) { create(:league) }

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

  describe "#downcase_email" do
    it "makes the email attribute lower case" do
      league_invite = LeagueInvite.new(email: "BARRYWALLACE.IS@GMAIL.COM", league: league)
      league_invite.downcase_email
      expect(league_invite.email).to eq("barrywallace.is@gmail.com")
    end

    it "downcases an email before saving" do
      league_invite = LeagueInvite.new(email: "BARRYWALLACE.IS@GMAIL.COM", league: league)
      expect(league_invite.save).to be_truthy
      expect(league_invite.email).to eq("barrywallace.is@gmail.com")
    end
  end
end
