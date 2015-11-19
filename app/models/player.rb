class Player < ActiveRecord::Base
	has_many :team_players, dependent: :destroy
	has_many :player_game_weeks, dependent: :destroy
	validates :first_name, presence: true
	validates :last_name, presence: true

	def full_name
		"#{first_name} #{last_name}"
	end
end
