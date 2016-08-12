require 'spec_helper'

describe "teams/show" do
  let!(:user) { create(:user) }
  let!(:competition) { create(:competition) }
  let!(:season) { create(:season, competition: competition) }
  let!(:league) { create(:league, competition: competition) }
  let!(:team) { create(:team, league: league, user: user) }

  before(:each) do
    @team = assign(:team, stub_model(Team,
      :title => "Title", :league_id => league.id, :user_id => user.id
    ))
  end
  let!(:stadium) { create(:stadium, team: @team) }

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
  end
end
