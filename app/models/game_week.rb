class GameWeek < ActiveRecord::Base
	belongs_to :season
	has_many :player_game_weeks, dependent: :destroy
	has_many :games, dependent: :destroy
	validates :starts_at, :ends_at, :overlap => {:scope => "season_id"}
	validates :starts_at, :ends_at, :game_week_number, presence: true
	validates :game_week_number, numericality: { greater_than: 0 }
	validates :game_week_number, uniqueness: { scope: :season, message: "a game week only happens once per season" }
	
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
