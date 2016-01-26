class GameRound < ActiveRecord::Base
	belongs_to :season
	belongs_to :league
	has_many :games
	validates_uniqueness_of :game_round_number, scope: [:season, :league]
end
