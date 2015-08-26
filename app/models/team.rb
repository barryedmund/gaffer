class Team < ActiveRecord::Base
	belongs_to :user
	has_many :team_players
	validates :title, presence: true
	validates :title, length: { minimum: 3}
end
