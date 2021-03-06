require 'spec_helper'

describe Contract do

  let!(:team){create(:team)}

  let!(:player){create(:player)}

  let!(:squad_position){create(:squad_position)}

  let!(:team_player){TeamPlayer.create(:team => team, :player => player, :squad_position => squad_position)}

  let!(:contract){ Contract.create(
    weekly_salary_cents: 12000001,
    team: team,
    team_player: team_player,
    starts_at: Date.today,
    ends_at: Date.today + 100.days) }

  let!(:contract_with_negative_salary){Contract.create(:weekly_salary_cents => -1000000, :team => team, team_player: team_player, :starts_at => Date.today, :ends_at => (Date.today).advance(:days => 700))}

  let!(:contract_with_low_salary){Contract.create(:weekly_salary_cents => 200, :team => team, team_player: team_player, :starts_at => Date.today, :ends_at => (Date.today).advance(:days => 700))}

  let!(:contract_with_end_date_in_the_past){Contract.create(:weekly_salary_cents => 1000000, :team => team, team_player: team_player, :starts_at => (Date.today).advance(:days => -800), :ends_at => (Date.today).advance(:days => -700))}

  let!(:contract_with_start_date_after_end_date){Contract.create(:weekly_salary_cents => 200000, :team => team, team_player: team_player, :starts_at => (Date.today).advance(:days => 800), :ends_at => (Date.today).advance(:days => 700))}

  let!(:short_contract) { Contract.create(weekly_salary_cents: 200000, team: team, team_player: team_player, starts_at: Date.today, ends_at: Date.today.advance(days: 1)) }

  let!(:long_contract) { Contract.create(weekly_salary_cents: 200000, team: team, team_player: team_player, starts_at: Date.today, ends_at: Date.today.advance(days: 5000)) }

  let!(:first_signed_contract){Contract.create(:weekly_salary_cents => 12000000, :team => team, team_player: team_player, :starts_at => Date.today, :ends_at => (Date.today).advance(:days => 700), signed: true)}

  let!(:second_signed_contract){Contract.create(:weekly_salary_cents => 13000000, :team => team, team_player: team_player, :starts_at => Date.today, :ends_at => (Date.today).advance(:days => 700), signed: true)}

  let!(:same_player_and_team_contract_1) { Contract.create(weekly_salary_cents: 25000,
                                                          team: team,
                                                          starts_at: Date.today,
                                                          ends_at: (Date.today).advance(:days => 700),
                                                          signed: false,
                                                          player: player) }
  let!(:same_player_and_team_contract_2) { Contract.create(weekly_salary_cents: 35000,
                                                          team: team,
                                                          starts_at: Date.today,
                                                          ends_at: (Date.today).advance(:days => 400),
                                                          signed: false,
                                                          player: player) }

  context "relationships" do
    it {should belong_to(:team)}
    it {should belong_to(:team_player)}
  end

  context "validations" do
    it "should have a positive weekly salary" do
      expect(contract_with_negative_salary).to_not be_valid
    end

    it "should have a reasonable weekly salary" do
      expect(contract_with_low_salary).to_not be_valid
    end

    it "validate presence of weekly salary" do
      expect(contract).to validate_presence_of(:weekly_salary_cents)
    end

    it "validate presence of team" do
      expect(contract).to validate_presence_of(:team)
    end

    it "validate presence of start date" do
      expect(contract).to validate_presence_of(:starts_at)
    end

    it "validate presence of end date" do
      expect(contract).to validate_presence_of(:ends_at)
    end

    it "validate end date is in the future" do
      expect(contract_with_end_date_in_the_past).to_not be_valid
    end

    it "validate start date is before end date" do
      expect(contract_with_start_date_after_end_date).to_not be_valid
    end

    it "validates length when too short" do
      expect(short_contract).to_not be_valid
    end

    it "validates length when too long" do
      expect(long_contract).to_not be_valid
    end

    it "validates that a team player can only have one signed contract at once" do
      expect(second_signed_contract).to_not be_valid
    end

    it "validates that a team can't offer the same player two contracts" do
      expect(same_player_and_team_contract_2).to_not be_valid
    end
  end
end
