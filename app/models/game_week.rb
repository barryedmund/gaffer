class GameWeek < ActiveRecord::Base
	belongs_to :season
	belongs_to :league_season
	has_many :player_game_weeks, dependent: :destroy
	has_many :games, dependent: :destroy
	validates :season_id, :starts_at, :ends_at, :presence => true
	validates :starts_at, :ends_at, :overlap => {:scope => "season_id"}
	
	def self.get_current_game_week
	    @now = Date.today
	    if current_game_week = GameWeek.where('DATE(?) BETWEEN starts_at AND ends_at', @now).first
	      current_game_week
		end
	end

	def self.has_current_game_week?
		@now = Date.today
		GameWeek.where('DATE(?) BETWEEN starts_at AND ends_at', @now).any?
	end
end
