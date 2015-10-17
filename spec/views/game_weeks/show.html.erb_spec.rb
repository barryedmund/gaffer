require 'spec_helper'

RSpec.describe "game_weeks/show", :type => :view do
  before(:each) do
    @game_week = assign(:game_week, GameWeek.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
