require 'spec_helper'

describe "teams/show" do
  let!(:league) { create(:league) }
  let!(:user) { create(:user) }

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
