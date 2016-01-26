class SquadPosition < ActiveRecord::Base
	has_many :team_players
	has_many :player_lineups
	validates :short_name, presence: true
end
