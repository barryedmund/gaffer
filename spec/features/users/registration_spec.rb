require "spec_helper"

describe "Signing up" do
	let!(:competition) { create(:competition) }
	it "allows a user to sign up for the site and creates the object in the database" do
		expect(User.count).to eq(0)

		visit "/"
		expect(page).to have_content("Sign Up")
		click_link "Sign Up"

		fill_in "First Name", with: "Barry"
		fill_in "Last Name", with: "Wallace"
		fill_in "signup_email", with: "barrywallace.is@gmail.com"
		fill_in "signup_password", with: "password12345"
		fill_in "Password (again)", with: "password12345"
		click_button "Sign Up"

		expect(User.count).to eq(1)
	end
end
