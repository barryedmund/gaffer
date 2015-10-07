FactoryGirl.define do 
	factory :user do
		first_name "First"
		last_name "Last"
		sequence(:email) { |n| "user#{n}@gaffer.com"}
		password "gaffer123"
		password_confirmation "gaffer123"
	end

	factory :league do
    	name "MyString"
    	user
  	end

	factory :player do
	    first_name "Paul"
		last_name "Pogba"
  	end

	factory :team do
		title "Fantasy Playas"
		user
		league
	end
end
