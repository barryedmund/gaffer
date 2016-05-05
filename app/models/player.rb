class Player < ActiveRecord::Base
	has_many :team_players, dependent: :destroy
	has_many :player_game_weeks, dependent: :destroy
	validates :first_name, :last_name, :playing_position, :pl_player_code, presence: true

	def full_name
		"#{first_name} #{last_name}"
	end
end
