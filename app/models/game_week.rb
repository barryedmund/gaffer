class GameWeek < ActiveRecord::Base
	belongs_to :season
	has_many :player_game_weeks
	has_many :games
	validates :season_id, :starts_at, :ends_at, :presence => true
	validates :starts_at, :ends_at, :overlap => {:scope => "season_id"}
	
	def self.get_current_game_week
	    @now = Time.new
	    if current_game_week = GameWeek.where('DATETIME(?) BETWEEN starts_at AND ends_at', @now).first
	      current_game_week
		end
	end

	def self.has_current_game_week?
		@now = Time.new
		GameWeek.where('DATETIME(?) BETWEEN starts_at AND ends_at', @now).any?
	end
end
