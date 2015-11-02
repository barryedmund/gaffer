class SquadPosition < ActiveRecord::Base
	has_many :team_players
	validates :short_name, presence: true
end
