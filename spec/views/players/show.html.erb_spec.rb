require 'spec_helper'

RSpec.describe "players/show", :type => :view do
  let!(:competition) { create(:competition) } 
  before(:each) do
    @player = assign(:player, Player.create!(
      :first_name => "First Name",
      :last_name => "Last Name",
      playing_position: "Midfield",
      pl_player_code: 12345,
      competition: competition
    ))
  end
end
