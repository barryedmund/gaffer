require 'spec_helper'

describe LeagueSeason do
  let!(:league){ create(:league) }
  let!(:season){ create(:season) }

  context "relationships" do
    it {should belong_to(:season)}
    it {should belong_to(:league)}
  end 
end
