require "spec_helper"

describe "Logging in" do
	it "logs the user in and goes to the user page" do
		User.create(first_name: "Barry", last_name: "Wallace", email: "barrywallace.is@gmail.com", password: "testing123")
		visit new_user_session_path
		fill_in "login_email", with: "barrywallace.is@gmail.com"
		fill_in "Password", with: "testing123"
		click_button "Log in"

		expect(page).to have_content("Welcome back Barry!")
	end

	it "displays the email address in the event of a failed login" do
		visit new_user_session_path
		fill_in "login_email", with: "barrywallace.is@gmail.com"
		fill_in "Password", with: "wrong"
		click_button "Log in"

		expect(page).to have_content("Please check your email and password")
		expect(page).to have_field("login_email", with: "barrywallace.is@gmail.com")
	end
end
