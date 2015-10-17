class Player < ActiveRecord::Base
	has_many :team_players
	has_many :game_weeks
	validates :first_name, presence: true
	validates :last_name, presence: true

	def full_name
		"#{first_name} #{last_name}"
	end
end
