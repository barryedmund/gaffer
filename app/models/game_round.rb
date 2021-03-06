class GameRound < ActiveRecord::Base
  belongs_to :league_season
	has_many :games, dependent: :destroy
	validates_uniqueness_of :game_round_number, scope: [:league_season]
end
