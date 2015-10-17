task :fake => :environment do
	600.times do
		Player.create(	first_name: Faker::Name.first_name,
						last_name: Faker::Name.last_name)
	end
	
end