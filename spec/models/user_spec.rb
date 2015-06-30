require 'spec_helper'

describe User do
  let(:valid_attributes){
  	{
  		first_name: "Barry",
  		last_name: "Wallace",
  		email: "barrywallace.is@gmail.com"
  	}
  }

  context "validations" do
  	let(:user) {
  		User.new(valid_attributes)
  	}
  	
  	before do
  		User.create(valid_attributes)
  	end

  	it "requires an email" do
  		expect(user).to validate_presence_of(:email)
  	end

  	it "requires a unique email" do
  		expect(user).to validate_uniqueness_of(:email)
  	end

  	it "requires a unique email (case insensitive)" do
  		user.email = "BARRYWALLACE.IS@GMAIL.COM"
  		expect(user).to validate_uniqueness_of(:email)
  	end
  end

  describe "#downcase_email" do
  	it "makes the email attribute lower case" do
  		user = User.new(valid_attributes.merge(email: "BARRYWALLACE.IS@GMAIL.COM"))
  		user.downcase_email
  		expect(user.email).to eq("barrywallace.is@gmail.com")
  	end

  	it "downcases an email before saving" do
  		user = User.new(valid_attributes)
  		user.email = "BOBBELCHER@GMAIL.COM"
  		expect(user.save).to be_true
  		expect(user.email).to eq("bobbelcher@gmail.com")
  	end
  end
end
