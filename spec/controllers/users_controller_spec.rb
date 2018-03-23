require 'spec_helper'

describe UsersController do
  let(:valid_attributes_with_invite){
    {
      "first_name" => "MyString",
      "last_name" => "LastName",
      "email" => "email@example.com",
      "password" => "password12345",
      "password_confirmation" => "password12345"
    }
  }
  let(:valid_attributes){
    {
      "first_name" => "MyString",
      "last_name" => "LastName",
      "email" => "email_2@example.com",
      "password" => "password12345",
      "password_confirmation" => "password12345"
    }
  }
  let!(:league) { create(:league) }
  let!(:league_invite) { create(:league_invite, league: league, email: "email@example.com") }

  let(:valid_session) { {} }

  describe "GET new" do
    it "assigns a new user as @user" do
      get :new, {}, valid_session
      assigns(:user).should be_a_new(User)
    end
  end

  describe "GET edit" do
    it "assigns the requested user as @user" do
      user = User.create! valid_attributes
      get :edit, {:id => user.to_param}, valid_session
      assigns(:user).should eq(user)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new User" do
        expect {
          post :create, {:user => valid_attributes}, valid_session
        }.to change(User, :count).by(1)
      end

      it "assigns a newly created user as @user" do
        post :create, {:user => valid_attributes}, valid_session
        assigns(:user).should be_a(User)
        assigns(:user).should be_persisted
      end

      it "redirects to root path when user has invites" do
        post :create, {:user => valid_attributes_with_invite}, valid_session
        response.should redirect_to(root_path)
      end

      it "redirects to league creation when user has no invites" do
        post :create, {:user => valid_attributes}, valid_session
        response.should redirect_to(new_league_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved user as @user" do
        # Trigger the behavior that occurs when invalid params are submitted
        User.any_instance.stub(:save).and_return(false)
        post :create, {:user => { "first_name" => "invalid value" }}, valid_session
        assigns(:user).should be_a_new(User)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        User.any_instance.stub(:save).and_return(false)
        post :create, {:user => { "first_name" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested user" do
        user = User.create! valid_attributes
        User.any_instance.should_receive(:update).with({ "first_name" => "MyString" })
        put :update, {:id => user.to_param, :user => { "first_name" => "MyString" }}, valid_session
      end

      it "assigns the requested user as @user" do
        user = User.create! valid_attributes
        put :update, {:id => user.to_param, :user => valid_attributes}, valid_session
        assigns(:user).should eq(user)
      end

      it "redirects to the user" do
        user = User.create! valid_attributes
        put :update, {:id => user.to_param, :user => valid_attributes}, valid_session
        response.should redirect_to(user)
      end

      it "sets the session user_id to the created user" do
        post :create, { :user => valid_attributes }, valid_session
        expect(session[:user_id]).to eq(User.find_by(email: valid_attributes["email"]).id)
      end
    end

    describe "with invalid params" do
      it "assigns the user as @user" do
        user = User.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        User.any_instance.stub(:save).and_return(false)
        put :update, {:id => user.to_param, :user => { "first_name" => "invalid value" }}, valid_session
        assigns(:user).should eq(user)
      end

      it "re-renders the 'edit' template" do
        user = User.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        User.any_instance.stub(:save).and_return(false)
        put :update, {:id => user.to_param, :user => { "first_name" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested user" do
      user = User.create! valid_attributes
      expect {
        delete :destroy, {:id => user.to_param}, valid_session
      }.to change(User, :count).by(-1)
    end

    it "redirects to the users list" do
      user = User.create! valid_attributes
      delete :destroy, {:id => user.to_param}, valid_session
      response.should redirect_to(users_url)
    end
  end

end
