require 'spec_helper'

describe Team do
  it {should have_many(:team_players)}
end
