require 'spec_helper'

describe Season do
	context "relationships" do
	  it { should have_many(:game_weeks) }
	end
end