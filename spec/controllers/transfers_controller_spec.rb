require 'spec_helper'

RSpec.describe TransfersController, :type => :controller do

	let(:valid_session) { {} }
	let!(:user) { create(:user) }
  let!(:league) { create(:league) }

	before do
    sign_in(user)
  end

	describe "GET new" do
    it "assigns a new transfer as @transfer" do
      get :new, {:league_id => league}, valid_session
      expect(assigns(:transfer)).to be_a_new(Transfer)
    end
  end
end
