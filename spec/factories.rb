FactoryGirl.define do
	factory :user do
		first_name "First"
		last_name "Last"
		sequence(:email) { |n| "user#{n}@gaffer.com"}
		password "gaffer123"
		password_confirmation "gaffer123"
	end

	factory :team do
		title "Fantasy Playas"
		user
	end
end
