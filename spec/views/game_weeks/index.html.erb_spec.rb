require 'spec_helper'

RSpec.describe "game_weeks/index", :type => :view do
  before(:each) do
    assign(:game_weeks, [
      GameWeek.create!(),
      GameWeek.create!()
    ])
  end

  it "renders a list of game_weeks" do
    render
  end
end
