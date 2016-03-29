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
end
