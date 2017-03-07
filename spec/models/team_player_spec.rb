require 'spec_helper'

describe TeamPlayer do
  let!(:team){create(:team)}

  let!(:player){create(:player)}

  let!(:squad_position){create(:squad_position)}

  let!(:team_player){TeamPlayer.create(:team => team, :player => player, :squad_position => squad_position)}
  
  context "relationships" do
    it {should belong_to(:team)}
    it {should belong_to(:squad_position)}
    it {should have_many(:contracts)}
  end

  context "validations" do
    it "validate presence of squad_position" do
      expect(team_player).to validate_presence_of(:squad_position_id)
    end
  end

  context "if eligible" do
    before { allow(subject).to receive(:transfer_completes_at?).and_return(true) }
    it { should validate_presence_of(:transfer_minimum_bid) }
  end

  context "if ineligible" do
    before { allow(subject).to receive(:transfer_completes_at?).and_return(false) }
    it { should_not validate_presence_of(:transfer_minimum_bid) }
  end

  context "if eligible" do
    before { allow(subject).to receive(:transfer_minimum_bid?).and_return(true) }
    it { should validate_presence_of(:transfer_completes_at) }
  end

  context "if ineligible" do
    before { allow(subject).to receive(:transfer_minimum_bid?).and_return(false) }
    it { should_not validate_presence_of(:transfer_completes_at) }
  end
end
